pdf:
	pandoc --pdf-engine /Library/TeX/texbin/pdflatex --biblio whitepaper.bib --csl ieee.csl --mathjax --number-sections --citeproc -f markdown -o whitepaper.pdf whitepaper.md

.PHONY: pdf
