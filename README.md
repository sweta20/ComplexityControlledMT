# Complexity Controlled MT

This repository contains implementations for

Sweta Agrawal and Marine Carpuat, "Controlling Text Complexity in Neural Machine Translation", EMNLP-IJCNLP 2019.

## Usage Instructions
1. Run bash [setup.sh](setup.sh) to obtain necessary software.
2. You can request the Newsela dataset and the OPUS corpus from [here](https://newsela.com/data/) and [here](http://opus.nlpl.eu/) respectively.
3. Use PrepareDataFiles.ipynb to extract alignments and create dev/train/test split and put it under data/.
4. For Training
```bash
Monolingual English Simplification 
> bash scripts/main.sh -d -i <iter>

Multitask model trained on English Simplification and out-of-domain bilingual data
> bash scripts/main.sh -d -b -i <iter>

Other options:
> bash scripts/main.sh -h
```
5. Evaluation: You can evaluate on the complexity controlled MT task by using the c flag

```bash
> bash scripts/evaluate.sh -i <iter> -c

Other options:
> bash scripts/evaluate.sh -h
```

To evaluate the pipeline model, you need to supply the ids for the first and the second model and a name for the evaluation. So if 1 represents the translation model (ES-EN) and 2 represents the simplification model (EN-EN), you can use the following script to evaluate the pipeline translate-then-simplify.

```bash
> bash scripts/evaluate_pipeline.sh -i 1 -j 3 -k esen

```

Some of the scripts for this work were modified from [here](https://github.com/xingniu/multitask-ft-fsmt). Also, the scripts to calculate SARI score and ARI readability index were referred from [here](https://github.com/cocoxu/simplification) and [here](https://github.com/mmautner/readability) respectively. 

Note: Please refer to the supplementary material of our paper (Table 10 and 11) for exact statistics of the dataset used for training. 

