#!/bin/bash

lang_ds=$lang_base
lang_src=$bilingual_lang_src

if [[ $ari == True ]]; then
	echo " * Preparing bilingual data with ARI token.* ..."
	head -n $select_n $bilingual_data_dir.ari.$lang_src > $select_data.$lang_src
elif [[ $flesch == True ]]; then
	echo " * Preparing bilingual data with Flesch token.* ..."
	head -n $select_n $bilingual_data_dir.flesch.$lang_src > $select_data.$lang_src
else
	echo " * Preparing bilingual data without grade token.* ..."
	head -n $select_n $bilingual_data_dir.$lang_src > $select_data.$lang_src
fi


head -n $select_n $bilingual_data_dir.$lang_ds > $select_data.$lang_ds

### Cleaning selected parallel data
if [ ! -f $select_data.clean.$lang_ds ]; then
	echo " * Cleaning selected parallel data $select_data.* ..."
	$moses_scripts_path/training/clean-corpus-n.perl \
		-ratio 3        \
		$select_data     \
		$lang_src $lang_ds \
		$select_data.clean \
		1 1000
fi;

# ln -srf $select_data.clean.$lang_src $data_dir/bilingual.$type_1
# ln -srf $select_data.clean.$lang_ds $data_dir/bilingual.$type_2
