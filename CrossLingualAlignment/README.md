# Cross-lingual Segment Aligner tool

This repository contains implementation for the aligner described in Section 4.1 of our paper.

## Usage instructions

1. Install numpy, nltk, massalign, google-api-translate and google-cloud-translate
2. Get Google Translate credits from [here](https://cloud.google.com/translate/docs/quickstart) 
3. Getting alignments
```bash
	python align.py --source-file <path to Spanish article> --target-file <path to English article>
```


## References

- Gustavo H. Paetzold, Fernando Alva-Manchego and Lucia Specia. **MASSAlign: Alignment and Annotation for Comparable Documents**. Proceedings of the 2017 IJCNLP.
- Gustavo H. Paetzold and Lucia Specia. **Vicinity-Driven Paragraph and Sentence Alignment for Comparable Corpora**. arXiv preprint arXiv:1612.04113.
- https://www.nltk.org/
- https://code.google.com/archive/p/gachalign/
- https://pypi.org/project/google-cloud-translate/
- https://pypi.org/project/google-api-translate/
