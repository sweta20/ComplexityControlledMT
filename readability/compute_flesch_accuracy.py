import sys
from readability import Readability
import argparse
from tqdm import tqdm 
import pickle
from sklearn.metrics import mean_squared_error
from math import sqrt
import numpy

def clip_val(x, min_val=1, max_val=13):
    if(x<min_val):
        return min_val
    elif(x>max_val):
        return max_val
    else:
        return x

def get_text_flesch_grade_score(inp_text):
    rd = Readability(inp_text.strip())
    return rd.FleschKincaidGradeLevel()

def compute_flesch_accuracy(ref_file, pred_file):
    with open(ref_file) as f:
        ref_data = f.readlines()
    with open(pred_file) as f:
        pred_data = f.readlines()

    acc = []
    pred_grades = []
    tgt_grades = []
    for i in tqdm(range(len(ref_data))):
        try:
            flesch_ref_grade =  get_text_flesch_grade_score(ref_data[i])
            flesch_pred_grade =  get_text_flesch_grade_score(pred_data[i])
            pred_grades.append(flesch_pred_grade)
            tgt_grades.append(flesch_ref_grade)
            acc.append(int(abs(flesch_ref_grade-flesch_pred_grade) <=1))
        except:
            continue

    # with open("flesch_grade.tgt","wb") as f:
    #     pickle.dump(tgt_grades, f)
    # with open("ari_grade.pred","wb") as f:
    #     pickle.dump(pred_grades, f)

    score = sum(acc)/len(acc)
    print("FLESCH accuracy: " + str(score))

    rms = sqrt(mean_squared_error(tgt_grades, pred_grades))
    print("RMSE FLESCH: " + str(rms))

    corr = numpy.corrcoef(tgt_grades, pred_grades)
    print("Corre FLESCH: " + str(corr))

def main():
    arg_parser = argparse.ArgumentParser(description='Compute FLESCH adjacency accuracy')
    arg_parser.add_argument('--ref_file', type=str, default=None)
    arg_parser.add_argument('--pred_file', type=str, default=None)
    args = arg_parser.parse_args()
    compute_flesch_accuracy(args.ref_file, args.pred_file)

if __name__ == '__main__':
    main() 