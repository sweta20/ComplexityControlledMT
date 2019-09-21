#! /bin/bash
root_dir=`dirname $0`/..
gpus=0

## pipeline parameters
src_max_len=101
tgt_max_len=100
bpe_num_operations=32000
lang_base=en

type_1=src
type_2=tgt

## software bins
moses_scripts_path=$root_dir/moses-scripts
bpe_scripts_path=$root_dir/subword-nmt/subword_nmt
kenlm_path=$root_dir/kenlm/build/bin

## experiment naming variables
base_dir=$root_dir/experiments
mkdir -p $base_dir

## data settings
monolingual=False
newsela_eq=False
newsela_neq=False
bilingual=False

## Grade in eq and not eq
grade_eq=False
grade_neq=False

## Other settings
oversample=False
ari=False
spanish=False
flesch=False
reverse=False
id=1

## Model choice
model=simple
reconstruct=False

while getopts ":m:i:denbgfhaskr" opt; do
	case $opt in
		m)
			model=$OPTARG ;;
		i)
			id=$OPTARG ;;
		d)
			monolingual=True ;;
		e) 
			newsela_eq=True ;;
		n) 
			newsela_neq=True ;;
		b)
			bilingual=True ;;
		g)
			grade_neq=True ;;
		f)
			grade_eq=True ;;
		s)
			spanish=True ;;
		a)
			ari=True;;
		k)
			flesch=True;;
		r)
			reverse=True;;
		h)
			echo "Usage: main.sh"
			echo "-m model (simple/complex)"
			echo "-i Run id"
			echo "-d monolingual English data"
			echo "-s monolingual Spanish data"
			echo "-e newsela eq data"
			echo "-n newsela neq data"
			echo "-b bilingual data"
			echo "-g Add grade to neq"
			echo "-f Add grade to eq"
			echo ""
			exit 0 ;;

    \?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1 ;;
    :)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1 ;;
	esac
done

## experiment files
data_dir=$root_dir/data
exp_dir=$base_dir
sub_exp_dir=$exp_dir/iter-$id

# Creating data folder
sub_data_dir=$sub_exp_dir/data
mkdir -p $sub_data_dir

train=$sub_data_dir/train
dev=$sub_data_dir/dev
test=$sub_data_dir/test

echo "Model: $model, Monolingual: $monolingual, Newsela_neq: $newsela_neq, \
Newsela_eq: $newsela_eq, Bilingual: $bilingual, Run Id: $id, Add Grade to neq: 
$grade_neq,  Add Grade to eq: $grade_eq,
Use ARI:$ari, Use Flesch:$flesch, Reverse Direction: $reverse"
echo "model=$model
d=$monolingual
n=$newsela_neq
e=$newsela_eq
b=$bilingual 
id=$id
g=$grade_neq
f=$grade_eq
a=$ari
s=$spanish
k=$flesch
r=$reverse" > $sub_exp_dir/config

# Preparing dataset
if [[ $ari == True ]]; then
	echo " * Preparing ari data.* ..."
	. $root_dir/scripts/prepare_ari_dataset.sh
elif [[ $flesch == True ]]; then
	echo " * Preparing flesch data.* ..."
	. $root_dir/scripts/prepare_flesch_dataset.sh
elif [[ $reverse == True ]]; then
	echo " * Preparing reverse direction data.* ..."
	. $root_dir/scripts/prepare_reverse_dataset.sh
else
	echo " * Preparing data.* ..."
	. $root_dir/scripts/prepare_dataset.sh
fi

echo " * Preprocessing data.* ..."
. $root_dir/scripts/preprocess.sh

echo " * Training the model.* ..."
prev_sub_exp_dir=$sub_exp_dir
model_dir=$sub_exp_dir/model-$id
. $root_dir/scripts/train.sh