#!/bin/bash

gpu_id=0

tc_model=$sub_data_dir/tc
bpe_model=$sub_data_dir/bpe

# Pre-processing test data
if [ ! -f $test_dir/test.tc ]; then
 	echo " * True-casing $test_src ..."
 	$moses_scripts_path/recaser/truecase.perl \
 		-model $tc_model                       \
 		< $test_src                             \
 		> $test_dir/test.tc
fi;
if [ ! -f $test_dir/test.tc.bpe ]; then
 	echo " * Applying BPE to $test_dir/test.tc ..."
 	python2 $bpe_scripts_path/apply_bpe.py \
 		--codes $bpe_model                  \
 		< $test_dir/test.tc                  \
 		> $test_dir/test.tc.bpe
fi;


if [ ! -f $test_dir/test.trans ]; then
	python3 -m sockeye.translate    \
		--input $test_dir/test.tc.bpe   \
		--output $test_dir/test.trans \
		--models $model_dir  \
		--ensemble-mode linear \
		--beam-size 5   \
		--batch-size 16  \
		--chunk-size 1024 \
		--device-ids $gpu_id \
		--disable-device-locking
fi;

detruecase=True

# Post-processing translations
if [ ! -f $test_dir/test.trans.detok ]; then
	echo " * Post-processing $test_dir/test.trans ..."
	if [[ $detruecase == False ]]; then
		cat $test_dir/test.trans \
			| sed -r 's/(@@ )|(@@ ?$)//g' 2>/dev/null \
			| $moses_scripts_path/tokenizer/detokenizer.perl -q -l en 2>/dev/null \
			> $test_dir/test.trans.detok
	else
		cat $test_dir/test.trans \
			| sed -r 's/(@@ )|(@@ ?$)//g' 2>/dev/null \
			| $moses_scripts_path/recaser/detruecase.perl 2>/dev/null \
			| $moses_scripts_path/tokenizer/detokenizer.perl -q -l en 2>/dev/null \
			> $test_dir/test.trans.detok
	fi;
fi;
