# # Evaluation
root_dir=`dirname $0`/..

## Software bins
metric_path=$root_dir/readability
sacrebleu_path=$root_dir/sockeye/contrib/sacrebleu
moses_scripts_path=$root_dir/moses-scripts
bpe_scripts_path=$root_dir/subword-nmt/subword_nmt
kenlm_path=$root_dir/kenlm/build/bin

id=2
eval_mono=False
eval_trans=False
eval_comp=False

while getopts "i:mtc" opt; do
	case $opt in
		i)
			id=$OPTARG ;;
		m)
			eval_mono=True ;;
		t)
			eval_trans=True ;;
		c)
			eval_comp=True ;;
		h)
			echo "Usage: evaluate.sh"
			echo "-i Run id"
			echo "-m Evaluate on monolingual data"
			echo "-t Evaluate on translation data"
			echo "-c Evaluate on complexity controlled data"
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
# Preparing test data
if [ $eval_mono == True ]; then
	echo " * Adding monolingual indomain data to test.src and test.tgt .* ..."
	cat $data_dir/test_en.$type_1 >> $sub_data_dir/test.src
	cat $data_dir/test_en.$type_2 >> $sub_data_dir/test.tgt
fi;

if [ $eval_trans == True ]; then
	echo " * Adding bilingual indomain equivalent grade data to test.src and test.tgt with grade level.* ..."
	cat $data_dir/test_esen_eq.$type_1 |  sed 's/^<\w*>\t\ *//' >> $sub_data_dir/test.src
	cat $data_dir/test_esen_eq.$type_2 |  sed 's/^<\w*>\t\ *//' >> $sub_data_dir/test.tgt
fi;

if [ $eval_comp == True ]; then
	echo " * Adding bilingual indomain not equivalent grade data to test.src and test.tgt with grade level.* ..."
	cat $data_dir/test_esen_neq.$type_1 >> $sub_data_dir/test.src
	cat $data_dir/test_esen_neq.$type_2 >> $sub_data_dir/test.tgt
fi;

echo " * Translating test sentences.* ..."
test_dir=$exp_dir/test-$id
model_dir=$exp_dir/model-$id
mkdir -p $test_dir
test_src=$sub_data_dir/test.src
. $root_dir/scripts/translate.sh

echo " * Evalutaing the model for run id $id* ..." 
test_src=$sub_data_dir/test.src
test_ref=$sub_data_dir/test.tgt
test_pred=$test_dir/test.trans.detok


# Separate english, eq, neq data
config_file=$exp_dir/config
echo $config_file
. $config_file
start=1

if [ $eval_mono == True ]; then
	count=($(wc -l $root_dir/data/test_en.src))
	end=$(($start+$count-1));
	echo "Evaluating on monolingual data: $start:$end"
	sed "$start,$end !d" < $test_src > $test_dir/test_en.src
	sed "$start,$end !d" < $test_ref > $test_dir/test_en.tgt
	sed "$start,$end !d" < $test_pred > $test_dir/test_en.pred
	src=$test_dir/test_en.src 
	tgt=$test_dir/test_en.tgt 
	pred=$test_dir/test_en.pred 
	start=$(($end+1));
	k=1
	. $root_dir/scripts/compute_metric.sh 
fi;

if [ $eval_trans == True ]; then
	count=($(wc -l $root_dir/data/test_esen_eq.src))
	end=$(($start+$count-1));
	echo "Evaluating on translation data:  $start:$end"
	sed "$start,$end !d" < $test_src > $test_dir/test_esen_eq.src
	sed "$start,$end !d" < $test_ref > $test_dir/test_esen_eq.tgt
	sed "$start,$end !d" < $test_pred > $test_dir/test_esen_eq.pred
	src=$root_dir/experiments/iter-1/test-1/test_esen_eq.pred
	tgt=$test_dir/test_esen_eq.tgt 
	pred=$test_dir/test_esen_eq.pred 
	start=$(($end+1));
	k=2
	. $root_dir/scripts/compute_metric.sh 
fi;

if [ $eval_comp == True ]; then
	count=($(wc -l $root_dir/data/test_esen_neq.src))
	end=$(($start+$count-1));
	echo "Evaluating on GSMT data:  $start:$end"
	sed "$start,$end !d" < $test_src > $test_dir/test_esen_neq.src
	sed "$start,$end !d" < $test_ref > $test_dir/test_esen_neq.tgt
	sed "$start,$end !d" < $test_pred > $test_dir/test_esen_neq.pred
	src=$root_dir/experiments/iter-1/test-1/test_esen_neq.pred
	tgt=$test_dir/test_esen_neq.tgt 
	pred=$test_dir/test_esen_neq.pred 
	start=$(($end+1));
	k=3
	. $root_dir/scripts/compute_metric.sh 
fi;
# Clear extra files
rm $sub_data_dir/test.src
rm $sub_data_dir/test.tgt

# count=($(wc -l $root_dir/data/test_es.src))
# end=$(($start+$count-1));
# echo "Evaluating on GSMT data:  $start:$end"
# sed "$start,$end !d" < $test_src > $test_dir/test_es.src
# sed "$start,$end !d" < $test_ref > $test_dir/test_es.tgt
# sed "$start,$end !d" < $test_pred > $test_dir/test_es.pred
# src=$test_dir/test_es.src 
# tgt=$test_dir/test_es.tgt 
# pred=$test_dir/test_es.pred 
# start=$(($end+1));
# k=4
# . $root_dir/scripts/compute_metric.sh
