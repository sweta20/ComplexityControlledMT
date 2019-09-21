# # Evaluation
root_dir=`dirname $0`/..

## Software bins
metric_path=$root_dir/readability
sacrebleu_path=$root_dir/sockeye/contrib/sacrebleu
moses_scripts_path=$root_dir/moses-scripts
bpe_scripts_path=$root_dir/subword-nmt/subword_nmt
kenlm_path=$root_dir/kenlm/build/bin


id=2

while getopts "i:" opt; do
	case $opt in
		i)
			id=$OPTARG ;;
		h)
			echo "Usage: evaluate.sh"
			echo "-i Run id"
			exit 0 ;;

    \?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1 ;;
    :)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1 ;;
	esac
done


exp_dir=$root_dir/experiments/iter-$id
sub_data_dir=$exp_dir/data
data_dir=$root_dir/data

type_1=src
type_2=tgt

## Preparing test data
echo " * Adding monolingual indomain data to test.src and test.tgt .* ..."
cat $data_dir/test_en.$type_1 >> $sub_data_dir/test.src
cat $data_dir/test_en_ari.$type_1 >> $sub_data_dir/test_ari.src
cat $data_dir/test_en.$type_2 >> $sub_data_dir/test.tgt

echo " * Adding bilingual indomain equivalent grade data to test.src and test.tgt with grade level.* ..."
cat $data_dir/test_esen_eq.$type_1 |  sed 's/^<\w*>\t\ *//' >> $sub_data_dir/test.src
cat $data_dir/test_esen_eq_ari.$type_1 |  sed 's/^<\w*>\t\ *//' >> $sub_data_dir/test_ari.src
cat $data_dir/test_esen_eq.$type_2 |  sed 's/^<\w*>\t\ *//' >> $sub_data_dir/test.tgt

echo " * Adding bilingual indomain not equivalent grade data to test.src and test.tgt with grade level.* ..."
cat $data_dir/test_esen_neq.$type_1 >> $sub_data_dir/test.src
cat $data_dir/test_esen_neq_ari.$type_1 >> $sub_data_dir/test_ari.src
cat $data_dir/test_esen_neq.$type_2 >> $sub_data_dir/test.tgt

echo " * Translating test sentences.* ..."
test_dir=$exp_dir/test
model_dir=$exp_dir/model-$id
mkdir -p $test_dir
test_src=$sub_data_dir/test_ari.src
. $root_dir/scripts/translate.sh

echo " * Evalutaing the model for run id $id* ..." 
test_src=$sub_data_dir/test_ari.src
test_ref=$sub_data_dir/test.tgt
test_pred=$test_dir/test.trans.detok


# Separate english, eq, neq data
config_file=$exp_dir/config
echo $config_file
. $config_file

start=1
count=($(wc -l $root_dir/data/test_en.src))
end=$(($start+$count-1));
echo "Evaluating on monolingual data: $start:$end"
sed "$start,$end !d" < $test_src > $test_dir/test_en_ari.src
sed "$start,$end !d" < $test_ref > $test_dir/test_en_ari.tgt
sed "$start,$end !d" < $test_pred > $test_dir/test_en_ari.pred
src=$test_dir/test_en_ari.src 
tgt=$test_dir/test_en_ari.tgt 
pred=$test_dir/test_en_ari.pred 
start=$(($end+1));
k=1
. $root_dir/scripts/compute_metric.sh 

count=($(wc -l $root_dir/data/test_esen_eq.src))
end=$(($start+$count-1));
echo "Evaluating on translation data:  $start:$end"
sed "$start,$end !d" < $test_src > $test_dir/test_esen_eq_ari.src
sed "$start,$end !d" < $test_ref > $test_dir/test_esen_eq_ari.tgt
sed "$start,$end !d" < $test_pred > $test_dir/test_esen_eq_ari.pred
src=$root_dir/experiments/iter-2/test-2/test_esen_eq.pred
tgt=$test_dir/test_esen_eq_ari.tgt 
pred=$test_dir/test_esen_eq_ari.pred 
start=$(($end+1));
k=2
. $root_dir/scripts/compute_metric.sh

count=($(wc -l $root_dir/data/test_esen_neq.src))
end=$(($start+$count-1));
echo "Evaluating on GSMT data:  $start:$end"
sed "$start,$end !d" < $test_src > $test_dir/test_esen_neq_ari.src
sed "$start,$end !d" < $test_ref > $test_dir/test_esen_neq_ari.tgt
sed "$start,$end !d" < $test_pred > $test_dir/test_esen_neq_ari.pred
src=$root_dir/result_neq_trans/test.trans.detok
tgt=$test_dir/test_esen_neq_ari.tgt 
pred=$test_dir/test_esen_neq_ari.pred 
start=$(($end+1));
k=3
. $root_dir/scripts/compute_metric.sh

