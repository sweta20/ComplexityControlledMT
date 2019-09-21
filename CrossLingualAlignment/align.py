import os
import sys
import argparse
import pickle
from time import sleep
''' Path to massalign '''
sys.path.append("/usr/local/lib/python3.6/dist-packages/massalign")

from google_api_translate import Translator, TextUtils
from massalign.core import *
from gach import sentence_align
from nltk.tokenize.toktok import ToktokTokenizer

creds_path = "" # Google Translate Credentials json file path

def create_translation(src_file, output_file):
    lines = open(src_file, encoding='utf-8').read().strip().split('\n')
    if not os.path.exists(output_file):
        with open(output_file, "w") as f:
            for line in lines:
                if(line!=""):
                    success = False
                    while(not success):
                        try:
                            trans = Translator(creds_path=creds_path).translate(text=line, target_language='en')
                            f.write(trans.text if trans.text!="" else "\n\n")
                            success = True
                        except:
                            sleep(100)
                            continue
                else:
                    f.write("\n\n")             
    return True

def get_massalign_sentence_pairs(file1, file2):

    m = MASSAligner()

    #Train model over them:
    model = TFIDFModel([file1, file2], 'https://ghpaetzold.github.io/massalign_data/stop_words.txt')
    
    #Get paragraph aligner:
    paragraph_aligner = VicinityDrivenParagraphAligner(similarity_model=model, acceptable_similarity=0.3)

    #Get sentence aligner:
    sentence_aligner = VicinityDrivenSentenceAligner(similarity_model=model, acceptable_similarity=0.21, similarity_slack=0.05)

    #Get paragraphs from the document:
    p1s = m.getParagraphsFromDocument(file1)
    p2s = m.getParagraphsFromDocument(file2)
    #Align paragraphs:
    alignments, aligned_paragraphs = m.getParagraphAlignments(p1s, p2s, paragraph_aligner)
    
    #Align sentences in each pair of aligned paragraphs:
    alignmentsl = []
    for a in aligned_paragraphs:
        p1 = a[0]
        p2 = a[1]
        alignments, aligned_sentences = m.getSentenceAlignments(p1, p2, sentence_aligner)
        
        alignmentsl.extend(aligned_sentences)
    return alignmentsl


def create_spanish_english_alignments(spa_file, eng_file, spa_trans_file):

    toktok = ToktokTokenizer()
    
    massalign_sentence_pairs = get_massalign_sentence_pairs(spa_trans_file, eng_file)
    
    ''' To map to original spanish segment, you can either store the translation
        at sentence level or use Gale church to get sentence alignments from the documents.
    '''
    translation_sentence_pairs = sentence_align(spa_file, spa_trans_file, 0.97, 1.8)
    
    pairs = []
    for eng_trans, eng_org in massalign_sentence_pairs:
        eng_simple_tok_1 = toktok.tokenize(eng_trans)
        
        spanish = ''
        prev_spa = ''
        for spa, eng in translation_sentence_pairs:
            eng_simple_tok_2 = toktok.tokenize(eng)
        
            I = len(set(eng_simple_tok_2).intersection(set(eng_simple_tok_1)))
            U = len(set(eng_simple_tok_2))
            try:
                percent_overlap = float(I)/U
                if percent_overlap > 0.5 and spa!=prev_spa:
                    spanish += spa
                    prev_spa = spa
                    break
            except:
                continue
        if spanish != '':
            pairs.append([spanish, eng_org])
    return pairs

def main():
    arg_parser = argparse.ArgumentParser(description='CrossLingual Alignment')
    arg_parser.add_argument('--src-file', type=str, default=None, required=True, help="path to Original spanish(source) article")
    arg_parser.add_argument('--tgt-file', type=str, default=None, required=True, help="path to english article to which the Spanish(source) article has to be aligned")
    arg_parser.add_argument('--trans-file', type=str, default="trans.txt", help="path to the location to store the spanish translated article")
    arg_parser.add_argument('--output-file', type=str, default="pairs.pkl", help="path to dump the aligned pairs")
    args = arg_parser.parse_args()

    src_file = args.src_file
    tgt_file = args.tgt_file
    trans_file = args.trans_file

    # Produce translation file
    create_translation(src_file, trans_file)

    alignment_pairs = create_spanish_english_alignments(src_file, tgt_file, trans_file)
    pickle.dump(alignment_pairs, open(args.output_file, "wb"))


if __name__ == '__main__':
    main()

