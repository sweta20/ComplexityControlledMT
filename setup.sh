#!/bin/bash

root_dir=`dirname $0`
mkdir $root_dir/data

# === Installing Sockeye v1.16.6 (Sockeye requires python3)
# Adjust parameters according to the official instruction: https://github.com/awslabs/sockeye
cd $root_dir
git clone https://github.com/awslabs/sockeye.git
cd sockeye
git checkout 7485330 # This commit is v1.16.6
pip install . --no-deps -r requirements.gpu-cu90.txt

# === Installing Moses scripts
cd $root_dir
git clone https://github.com/moses-smt/mosesdecoder.git
mv mosesdecoder/scripts moses-scripts
rm -rf mosesdecoder

# === Installing BPE scripts (BPE requires python2)
cd $root_dir
git clone https://github.com/rsennrich/subword-nmt.git

# === Installing KenLM
cd $root_dir
git clone https://github.com/kpu/kenlm.git
cd kenlm
mkdir -p build
cd build
cmake ..
make -j 4

# === Getting Newsela and opus data
