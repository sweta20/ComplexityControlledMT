import sys
from readability import Readability
import argparse
from tqdm import tqdm 
import pickle
from sklearn.metrics import mean_squared_error
from math import sqrt
import numpy


def clip_val(x, min_val=1, max_val=12):
    if(x<min_val):
        return min_val
    elif(x>max_val):
        return max_val
    else:
        return x

def get_text_ari_grade_score(inp_text):
    rd = Readability(inp_text.strip())
    return rd.ARI()

def compute_ari_accuracy(ref_file, pred_file):
    with open(ref_file) as f:
        ref_data = f.readlines()
    with open(pred_file) as f:
        pred_data = f.readlines()

    acc = []
    pred_grades = []
    tgt_grades = []
    for i in tqdm(range(len(ref_data))):
        try:
            ari_ref_grade =  get_text_ari_grade_score(ref_data[i])
            ari_pred_grade =  get_text_ari_grade_score(pred_data[i])
            pred_grades.append(ari_pred_grade)
            tgt_grades.append(ari_ref_grade)
            acc.append(int(abs(ari_ref_grade-ari_pred_grade) <=1))
        except:
            continue

    # with open("ari_grade.tgt","wb") as f:
    #     pickle.dump(tgt_grades, f)
    # with open("ari_grade.pred","wb") as f:
    #     pickle.dump(pred_grades, f)

    score = sum(acc)/len(acc)
    print("Adjcency ARI accuracy: " + str(score))

    rms = sqrt(mean_squared_error(tgt_grades, pred_grades))
    print("RMSE ARI: " + str(rms))

    corr = numpy.corrcoef(tgt_grades, pred_grades)
    print("Corre ARI: " + str(corr))


def main():
    arg_parser = argparse.ArgumentParser(description='Compute ARI adjacency accuracy')
    arg_parser.add_argument('--ref_file', type=str, default=None)
    arg_parser.add_argument('--pred_file', type=str, default=None)
    args = arg_parser.parse_args()
    compute_ari_accuracy(args.ref_file, args.pred_file)

if __name__ == '__main__':
    main() 