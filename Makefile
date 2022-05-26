pdf:
	pandoc --pdf-engine xelatex --biblio whitepaper.bib --csl ieee.csl --template=template.latex --mathjax --toc --number-sections --citeproc -f markdown -o whitepaper.pdf whitepaper.md

.PHONY: pdf
