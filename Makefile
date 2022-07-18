pdf:
	pandoc --pdf-engine /Library/TeX/texbin/pdflatex --biblio whitepaper.bib --csl ieee.csl --mathjax --number-sections --citeproc -f markdown -o whitepaper.pdf whitepaper.md

pdf2:
	pandoc --pdf-engine /Library/TeX/texbin/pdflatex --filter filter.py --biblio whitepaper.bib --csl ieee.csl --mathjax --toc --number-sections --citeproc -f markdown -o whitepaper.pdf whitepaper.md

.PHONY: pdf
