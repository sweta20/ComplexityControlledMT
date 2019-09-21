#!/bin/sh

root_dir=`dirname $0`/..

eval_name=esen
translate_first=False
id1=4
id2=1
gpu_id=0

while getopts "i:j:k:t" opt; do
    case $opt in
        i)
            id1=$OPTARG ;;
        j)
            id2=$OPTARG ;;
        k)
            eval_name=$OPTARG ;;
        t)
            translate_first=True;;
        h)
            echo "Usage: train.sh"
            echo "-i Run id1"
            echo "-j Run id2"
            echo "-k Name"
            exit 0 ;;

    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1 ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1 ;;
    esac
done

echo "eval_name: ${eval_name}, id1: $id1, id2: $id2, translate: $translate_first"

# simplification
data_dir=$root_dir/data
test_src="${data_dir}/test_${eval_name}_neq.src"
test_tgt="${data_dir}/test_${eval_name}_neq.tgt"

sacrebleu_path="${root_dir}/sockeye/contrib/sacrebleu"
moses_scripts_path="${root_dir}/moses-scripts"
bpe_scripts_path="${root_dir}/subword-nmt/subword_nmt"
metric_path="${root_dir}/readability"

tc_model="${root_dir}/experiments/iter-$id1/data/tc"
bpe_model="${root_dir}/experiments/iter-$id1/data/bpe"


results_dir="${root_dir}/pipeline_results/${eval_name}_${id1}_${id1}"
mkdir -p $results_dir

if [[ $translate_first == True ]]; then
    awk -F"\t" '{print $2}' $test_src > ${results_dir}/test.src
else
    cat $test_src > ${results_dir}/test.src
fi;

# Pre-processing test data
if [ ! -f ${results_dir}/test1.tc.bpe ]; then
    echo " * True-casing $test_src ..."
    $moses_scripts_path/recaser/truecase.perl \
        -model ${tc_model}                       \
        < ${results_dir}/test.src         \
        > ${results_dir}/test1.tc
    echo " * Applying BPE to ${results_dir}/test1.tc ..."
    python2 ${bpe_scripts_path}/apply_bpe.py \
        --codes ${bpe_model}                  \
        < ${results_dir}/test1.tc                  \
        > ${results_dir}/test1.tc.bpe
fi;

model1_dir="experiments/iter-$id2/model-$id1"
echo load models from ${model1_dir}

if [ ! -f ${results_dir}/test1.trans ]; then
    python3 -m sockeye.translate    \
        --input ${results_dir}/test1.tc.bpe   \
        --output ${results_dir}/test1.trans \
        --models ${model1_dir}  \
        --ensemble-mode linear \
        --beam-size 5   \
        --batch-size 16  \
        --chunk-size 1024 \
        --device-ids $gpu_id \
        --disable-device-locking
fi;

# Post-processing translations
cat ${results_dir}/test1.trans \
    | sed -r 's/(@@ )|(@@ ?$)//g' 2>/dev/null \
    | ${moses_scripts_path}/recaser/detruecase.perl 2>/dev/null \
    | ${moses_scripts_path}/tokenizer/detokenizer.perl -q -l en 2>/dev/null \
    > ${results_dir}/test1.trans.detok


if [[ $translate_first == True ]]; then
    awk -F"\t" '{print $1}' ${test_src}  > $results_dir/test.src.onlygrade
    paste $results_dir/test.src.onlygrade $results_dir/test1.trans.detok > $results_dir/test2.src

else
    cat ${results_dir}/test1.trans.detok > ${results_dir}/test2.src
fi;

test_src=${results_dir}/test2.src

tc_model=${root_dir}/experiments/iter-$id2/data/tc
bpe_model=${root_dir}/experiments/iter-$id2/data/bpe

# Pre-processing test data
if [ ! -f ${results_dir}/test2.tc.bpe ]; then
    echo " * True-casing $test_src ..."
    $moses_scripts_path/recaser/truecase.perl \
        -model ${tc_model}                       \
        < ${test_src}                             \
        > ${results_dir}/test2.tc
    echo " * Applying BPE to ${results_dir}/test.tc ..."
    python2 ${bpe_scripts_path}/apply_bpe.py \
        --codes ${bpe_model}                  \
        < ${results_dir}/test2.tc                  \
        > ${results_dir}/test2.tc.bpe
fi;


model2_dir="experiments/iter-$id2/model-$id2"
echo load models from ${model2_dir}


if [ ! -f ${results_dir}/test2.trans ]; then

    python3 -m sockeye.translate    \
        --input ${results_dir}/test2.tc.bpe   \
        --output ${results_dir}/test2.trans \
        --models ${model2_dir}  \
        --ensemble-mode linear \
        --beam-size 5   \
        --batch-size 16  \
        --chunk-size 1024 \
        --device-ids $gpu_id \
        --disable-device-locking

fi;

# Post-processing translations
cat ${results_dir}/test2.trans \
    | sed -r 's/(@@ )|(@@ ?$)//g' 2>/dev/null \
    | ${moses_scripts_path}/recaser/detruecase.perl 2>/dev/null \
    | ${moses_scripts_path}/tokenizer/detokenizer.perl -q -l en 2>/dev/null \
    > ${results_dir}/test2.trans.detok


echo " * Computing bleu * ..." 
python3 ${sacrebleu_path}/sacrebleu.py \
    ${test_tgt} \
    < ${results_dir}/test2.trans.detok \
    > ${results_dir}/bleu.log
cat ${results_dir}/bleu.log

echo " * Computing ARI * ..." 
python3 ${metric_path}/compute_ari_accuracy.py \
        --ref_file ${test_tgt} \
        --pred_file ${results_dir}/test2.trans.detok \
        > ${results_dir}/ari.log
cat ${results_dir}/ari.log

