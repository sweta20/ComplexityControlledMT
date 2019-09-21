#!/bin/bash
root_dir=`dirname $0`/..
gpu_id=0

moses_scripts_path=$root_dir/moses-scripts
bpe_scripts_path=$root_dir/subword-nmt/subword_nmt

exp_dir=$root_dir/experiments
id=31
sub_exp_dir=$exp_dir/iter-$id
sub_data_dir=$sub_exp_dir/data
model_dir=$sub_exp_dir/model-$id

tc_model=$sub_data_dir/tc
bpe_model=$sub_data_dir/bpe

test_dir=$root_dir/transformer
mkdir -p $test_dir

data_dir=$root_dir/data
# cat $data_dir/test.src >> $test_dir/test.src
# cat $test_dir/test_esen_neq.src |  sed 's/^<\w*>\t\ *//' >> $test_dir/test.src
# cat $root_dir/results_pipeline_2_esen_simplify/test.trans.detok >> $test_dir/test.src

test_src=$test_dir/test.src_new

# Pre-processing test data
echo " * True-casing $test_src ..."
$moses_scripts_path/recaser/truecase.perl \
	-model $tc_model                       \
	< $test_src                             \
	> $test_dir/test.tc

echo " * Applying BPE to $test_dir/test.tc ..."
python2 $bpe_scripts_path/apply_bpe.py \
	--codes $bpe_model                  \
	< $test_dir/test.tc                  \
	> $test_dir/test.tc.bpe


python3 -m sockeye.translate    \
	--input $test_dir/test.tc.bpe   \
	--output $test_dir/test.trans \
	--models $model_dir  \
	--ensemble-mode linear \
	--beam-size 5   \
	--batch-size 32  \
	--chunk-size 1024 \
	--device-ids $gpu_id \
	--disable-device-locking
	# --output-type align_plot 

detruecase=True

# Post-processing translations
echo " * Post-processing $test_dir/test.trans ..."
cat $test_dir/test.trans \
	| sed -r 's/(@@ )|(@@ ?$)//g' 2>/dev/null \
	| $moses_scripts_path/recaser/detruecase.perl 2>/dev/null \
	| $moses_scripts_path/tokenizer/detokenizer.perl -q -l en 2>/dev/null \
	> $test_dir/test.trans.detok

