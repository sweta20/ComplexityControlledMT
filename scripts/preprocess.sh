
# True-casing
tc_model=$sub_data_dir/tc
if [ ! -f $tc_model ]; then
	echo " * Training truecaser using $train.* ..."
	cat $train.$type_1.tmp $train.$type_2.tmp > $sub_data_dir/tc.corpus.tmp
	$moses_scripts_path/recaser/train-truecaser.perl \
		-corpus $sub_data_dir/tc.corpus.tmp           \
		-model $tc_model
	rm $sub_data_dir/tc.corpus.tmp
fi;
for data in train dev; do
	for type in $type_1 $type_2; do
		if [ -f ${!data}.$type.tmp ] && [ ! -f $sub_data_dir/$data.tok.tc.$type ]; then
			echo " * True-casing ${!data}.$type ..."
			$moses_scripts_path/recaser/truecase.perl \
				-model $tc_model                       \
				< ${!data}.$type.tmp                       \
				> $sub_data_dir/$data.tok.tc.$type
		fi;
	done;
done;


# Byte Pair Encoding (BPE)
bpe_model=$sub_data_dir/bpe
if [ ! -f $bpe_model ]; then
	echo " * Training BPE using $sub_data_dir/train.tok.tc.$type_2* ..."
	cat $sub_data_dir/train.tok.tc.$type_1 $sub_data_dir/train.tok.tc.$type_2 \
		| python2 $bpe_scripts_path/learn_bpe.py \
			-s $bpe_num_operations \
			> $bpe_model
fi;
for data in train dev; do
	for type in $type_1 $type_2; do
		if [ -f $sub_data_dir/$data.tok.tc.$type ] && [ ! -f $sub_data_dir/$data.tok.tc.bpe.$type ]; then
			echo " * Applying BPE to $sub_data_dir/$data.tok.tc.$type ..."
			python2 $bpe_scripts_path/apply_bpe.py \
				--codes $bpe_model                  \
				< $sub_data_dir/$data.tok.tc.$type   \
				> $sub_data_dir/$data.tok.tc.bpe.$type
		fi;
	done;
done;


for data in train dev; do
	for type in $type_1 $type_2; do
		if [ ! -f $sub_data_dir/$data.$type ]; then
			echo " * Creating final train and dev data and removing $data.$type ..."
			cat $sub_data_dir/$data.tok.tc.bpe.$type >>  $sub_data_dir/$data.$type
		fi;
	done;
done;

for data in train dev test; do
	for type in $type_1 $type_2; do
		if [ -f $sub_data_dir/$data.$type.tmp ]; then
			echo " * Removing $data.$type.tmp ..."
			rm $sub_data_dir/$data.$type.tmp
		fi;
	done;
done;