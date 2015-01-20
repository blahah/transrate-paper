all:
	pandoc -o draft.pdf -o draft.docx --bibliography=bib.bib 0*md

pdf: bib.bib
	pandoc -o draft.pdf --bibliography=bib.bib 0*md

docx: bib.bib
	pandoc -o draft.docx --bibliography=bib.bib 0*md

clean:
	$(RM) draft.pdf draft.docx
