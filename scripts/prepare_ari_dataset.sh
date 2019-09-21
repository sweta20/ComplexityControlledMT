for data in train dev; do
	echo " * Creating train and dev files . * ..." 
	touch $sub_data_dir/$data.src.tmp
	touch $sub_data_dir/$data.tgt.tmp
done;


if [[ $monolingual == True ]]; then
	echo " * Adding monolingual data to train.src and train.tgt .* ..."
	cat $data_dir/train_en_ari.$type_1 >> $sub_data_dir/train.src.tmp
	cat $data_dir/train_en.$type_2 >> $sub_data_dir/train.tgt.tmp

	echo " * Adding monolingual indomain data to dev.src and dev.tgt .* ..."
	cat $data_dir/dev_en_ari.$type_1 >> $sub_data_dir/dev.src.tmp
	cat $data_dir/dev_en.$type_2 >> $sub_data_dir/dev.tgt.tmp
fi;

if [[ $newsela_eq == True ]]; then
	if [[ $grade_eq == True ]]; then

		echo " * Adding bilingual indomain equivalent grade data to train.src and train.tgt with grade level.* ..."
		cat $data_dir/train_esen_eq_ari.$type_1 >> $sub_data_dir/train.src.tmp
		cat $data_dir/train_esen_eq.$type_2 >> $sub_data_dir/train.tgt.tmp

		echo " * Adding bilingual indomain equivalent grade data to dev.src and dev.tgt with grade level .* ..."
		cat $data_dir/dev_esen_eq_ari.$type_1 >> $sub_data_dir/dev.src.tmp
		cat $data_dir/dev_esen_eq.$type_2 >> $sub_data_dir/dev.tgt.tmp

	else

		echo " * Adding bilingual indomain equivalent grade data to train.src and train.tgt without grade level.* ..."
		cat $data_dir/train_esen_eq_ari.$type_1 |  sed 's/^<\w*>\t\ *//'   >> $sub_data_dir/train.src.tmp
		cat $data_dir/train_esen_eq.$type_2 |  sed 's/^<\w*>\t\ *//'   >> $sub_data_dir/train.tgt.tmp

		echo " * Adding bilingual indomain equivalent grade data to dev.src and dev.tgt without grade level .* ..."
		cat $data_dir/dev_esen_eq_ari.$type_1 |  sed 's/^<\w*>\t\ *//' >> $sub_data_dir/dev.src.tmp
		cat $data_dir/dev_esen_eq.$type_2 |  sed 's/^<\w*>\t\ *//' >> $sub_data_dir/dev.tgt.tmp
	fi;
fi;

if [[ $newsela_neq == True ]]; then
	if [[ $grade_neq == True ]]; then

		echo " * Adding bilingual indomain not equivalent grade data to train.src and train.tgt with grade level.* ..."
		cat $data_dir/train_esen_neq_ari.$type_1 >> $sub_data_dir/train.src.tmp
		cat $data_dir/train_esen_neq.$type_2 >> $sub_data_dir/train.tgt.tmp

		echo " * Adding bilingual indomain not equivalent grade data to dev.src and dev.tgt with grade level.* ..."
		cat $data_dir/dev_esen_neq_ari.$type_1 >> $sub_data_dir/dev.src.tmp
		cat $data_dir/dev_esen_neq.$type_2 >> $sub_data_dir/dev.tgt.tmp

	else

		echo " * Adding bilingual indomain not equivalent grade data to train.src and train.tgt without grade level.* ..."
		cat $data_dir/train_esen_neq_ari.$type_1 |  sed 's/^<\w*>\t\ *//'   >> $sub_data_dir/train.src.tmp
		cat $data_dir/train_esen_neq.$type_2 |  sed 's/^<\w*>\t\ *//'   >> $sub_data_dir/train.tgt.tmp

		echo " * Adding bilingual indomain not equivalent grade data to dev.src and dev.tgt without grade level.* ..."
		cat $data_dir/dev_esen_neq_ari.$type_1 | sed 's/^<\w*>\t\ *//' >> $sub_data_dir/dev.src.tmp
		cat $data_dir/dev_esen_neq.$type_2 | sed 's/^<\w*>\t\ *//' >> $sub_data_dir/dev.tgt.tmp
	fi;
fi;

if [[ $bilingual == True ]]; then

	bilingual_data_dir=$data_dir/bilingual_all
	bilingual_lang_src=es
	bilingual=$data_dir/bilingual

	echo " * Selecting size of bilingual corpus from $train.$type_1 * "
	# ari=False
	select_n=$(wc -l < $bilingual_data_dir.es)
	select_data=$data_dir/pool.$select_n.ari.$ari
	

	echo " * Preparing bilingual data.* ..."
	. $root_dir/scripts/get-bilingual-data.sh

	echo " * Adding bilingual out of domain data to train.src and train.tgt .* ..."
	cat $select_data.clean.$bilingual_lang_src >> $sub_data_dir/train.src.tmp
	cat $select_data.clean.$lang_ds >> $sub_data_dir/train.tgt.tmp

fi;
