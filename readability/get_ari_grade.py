import sys
from readability import Readability
import argparse

token = {'1':'<ONE>', '2': '<TWO>', '3': '<THREE>' , '4': '<FOUR>', '5': '<FIVE>', '6' : '<SIX>',
        '7': '<SEVEN>', '8':'<EIGHT>', '9' : '<NINE>', '10': '<TEN>', '11': '<ELEVEN>', '12' : '<TWELVE>',
        '13': '<THIRTEEN>'}
inv_map = {v: k for k, v in token.items()}

def clip_val(x, min_val=1, max_val=13):
    if(x<min_val):
        return min_val
    elif(x>max_val):
        return max_val
    else:
        return x

def get_text_ari_grade_score(inp_text):
    rd = Readability(inp_text.strip())
    return rd.ARI()

def create_ari_output_file(src_file, tgt_file):
    with open(src_file) as f:
        src_data = f.readlines()
    with open(tgt_file) as f:
        tgt_data = f.readlines()
    
    src_new_f = open(root + src_file.split("/")[-1].split(".")[0] + "_ari.src", "w")
    
    for i in tqdm(range(0,len(src_data))):
        ari_grade =  get_text_ari_grade_score(tgt_data[i])
        src_new_f.write(token[str(clip_val(int(ari_grade)))] + "\t" + src_data[i].split("\t")[-1])

def main():
    arg_parser = argparse.ArgumentParser(description='Add ARI token to source text')
    arg_parser.add_argument('--src_input_file', type=str, default=None)
    arg_parser.add_argument('--tgt_input_file', type=str, default=None)
    args = arg_parser.parse_args()
    create_ari_output_file(args.src_input_file, args.tgt_input_file)

if __name__ == '__main__':
    main() 