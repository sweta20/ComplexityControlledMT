#!/bin/bash
train_src=$sub_data_dir/train.src
train_tgt=$sub_data_dir/train.tgt
dev_src=$sub_data_dir/dev.src
dev_tgt=$sub_data_dir/dev.tgt

seed=1

# Training
gpu_ids=$(echo $gpus | sed "s/,/ /g")

if  [[ $model == transformer ]]; then
# # Model-3 weight tying + layer normalization
	echo " * Training Transformer based model.* ..."
	python3 -m sockeye.train \
			-s $train_src \
			-t $train_tgt \
			-vs $dev_src \
			-vt $dev_tgt \
			-o $model_dir \
			$model_args \
			--encoder transformer \
			--decoder transformer \
			--transformer-model-size 512 \
			--transformer-feed-forward-num-hidden 2048 \
			--transformer-attention-heads=8 \
			--transformer-dropout-attention=0.1 \
			--num-layers 6:6 \
			--num-words 50000:50000 \
			 --layer-normalization  \
			 --label-smoothing 0.1 \
			--num-embed 512 \
			--rnn-attention-type dot \
			--initial-learning-rate=0.0001 \
			--learning-rate-reduce-num-not-improved=8 \
			--learning-rate-reduce-factor=0.7 \
			--learning-rate-scheduler-type=plateau-reduce \
			--learning-rate-warmup=0 \
			--max-seq-len $src_max_len:$tgt_max_len \
			--batch-size 4096 \
			--batch-type word \
			--weight-tying-type src_trg_softmax \
			--weight-tying \
			--checkpoint-frequency 4000 \
			--keep-last-params 30 \
			--max-num-checkpoint-not-improved 32 \
			--decode-and-evaluate 1000 \
			--learning-rate-warmup 50000 \
			--seed $seed \
			 --disable-device-locking \
			 --device-ids $gpu_ids 
fi;


if  [[ $model == complex ]]; then
# # Model-2 weight tying + layer normalization
	echo " * Training Xing's Encoder Decoder model.* ..."
	python3 -m sockeye.train \
			-s $train_src \
			-t $train_tgt \
			-vs $dev_src \
			-vt $dev_tgt \
			-o $model_dir \
			--weight-tying \
			--layer-normalization \
			--weight-tying-type src_trg_softmax \
			$model_args \
			--encoder rnn \
			--decoder rnn \
			--rnn-cell-type lstm \
			--rnn-num-hidden 512 \
			--rnn-dropout-inputs .2:.2 \
			--rnn-dropout-states .2:.2 \
			--embed-dropout .2:.2 \
			--num-words 50000:50000 \
			--num-embed 512:512 \
			--rnn-attention-type dot \
			--max-seq-len $src_max_len:$tgt_max_len \
			--batch-size 128 \
			--checkpoint-frequency 1000 \
			--keep-last-params 30 \
			--max-num-checkpoint-not-improved 10 \
			--decode-and-evaluate 1000 \
			--seed $seed \
			--num-layers 1:1 \
			 --disable-device-locking \
			 --device-ids $gpu_ids 
fi;

if  [[ $model == simple ]]; then
# # Model-1:
	echo " * Training simple Encoder Decoder model.* ..."
	python3 -m sockeye.train \
			-s $train_src \
			-t $train_tgt \
			-vs $dev_src \
			-vt $dev_tgt \
			-o $model_dir \
			$model_args \
			--encoder rnn \
			--decoder rnn \
			--rnn-cell-type lstm \
			--rnn-num-hidden 500 \
			--rnn-dropout-states .3 \
			--num-embed 500 \
			--rnn-attention-type dot \
			--max-seq-len $src_max_len:$tgt_max_len \
			--batch-size 256 \
			--checkpoint-frequency 1000 \
			--keep-last-params 30 \
			--max-num-checkpoint-not-improved 8 \
			--decode-and-evaluate 1000 \
			--seed $seed \
			 --disable-device-locking \
			 --device-ids $gpu_ids 
fi;
