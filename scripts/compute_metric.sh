# ## Evaluation
root_dir=`dirname $0`/..

## Software bins
# metric_path=$root_dir/readability
# sacrebleu_path=$root_dir/sockeye/contrib/sacrebleu
# moses_scripts_path=$root_dir/moses-scripts
# bpe_scripts_path=$root_dir/subword-nmt/subword_nmt
# kenlm_path=$root_dir/kenlm/build/bin

# model_dir=$root_dir/experiments/iter-27/test-27
# k=2
# src=$test_dir/test_en.src
# tgt=$test_dir/test_en.tgt
# pred=$test_dir/test_en.src

echo "Source: $src, Target: $tgt, Pred: $pred, n: $n"

# BLEU
echo " * Computing bleu for run id $id* ..." 
if [ ! -f $test_dir/bleu_$k.log ]; then
	python3 $sacrebleu_path/sacrebleu.py \
		$tgt \
		< $pred \
		> $test_dir/bleu_$k.log
	cat $test_dir/bleu_$k.log
fi;

# SARI
echo " * Computing SARI for run id $id* ..." 
if [ ! -f $test_dir/sari_$k.log ]; then
	python3 $metric_path/SARI.py \
		--src_file $src \
		--ref_file $tgt \
		--out_file $pred \
		> $test_dir/sari_$k.log
	cat $test_dir/sari_$k.log
fi;

# ARI Accuracy
echo " * Computing ARI Accuracy for run id $id* ..." 
if [ ! -f $test_dir/ari_all_$k.log ]; then
	python3 $metric_path/compute_ari_accuracy.py \
		--ref_file $tgt \
		--pred_file $pred \
		> $test_dir/ari_all_$k.log
cat $test_dir/ari_all_$k.log
fi;

# FLESCH Accuracy
# echo " * Computing FLESCH Accuracy for run id $id* ..." 
# if [ ! -f $test_dir/flesch_$k.log ]; then
# 	python3 $metric_path/compute_flesch_accuracy.py \
# 		--ref_file $tgt \
# 		--pred_file $pred \
# 		> $test_dir/flesch_$k.log
# cat $test_dir/flesch_$k.log
# fi;

# # FleschReadingEase
# echo " * Computing flesch for run id $id* ..." 
# if [ ! -f $test_dir/flesch_$k.log ]; then
# 	python3 $metric_path/readability.py \
# 		--input_file $pred \
# 		> $test_dir/flesch_$k.log
# cat $test_dir/flesch_$k.log
# fi;

# Grade level Analysis
# grades=$(awk '{print $1}' $src | sort -u)
# grades_dir=$test_dir/grades
# for i in $grades; do  
# 	echo " * Bleu for grade level $i ..."
# 	awk -F\| 'NR==FNR{if($0 ~ '/$i/'){print $0}}' $src > $grades_dir/$i.src
# 	awk -F\| 'FNR==NR{if($0 ~ '/$i/'){l[FNR]=$0}; next}; FNR in l{print $0}'  $src $tgt > $grades_dir/$i.tgt
# 	awk -F\| 'FNR==NR{if($0 ~ '/$i/'){l[FNR]=$0}; next}; FNR in l{print $0}'  $src $pred > $grades_dir/$i.pred

# 	python3 $sacrebleu_path/sacrebleu.py \
# 			$grades_dir/$i.tgt \
# 			< $grades_dir/$i.pred \
# 			> $grades_dir/bleu_$i.log
# done;