DRAFTNAME = draft_$(shell date +'%y_%m_%d')

all: pdf docx

pdf: bib.bib
	pandoc -o $(DRAFTNAME).pdf --bibliography=bib.bib 0*md

docx: bib.bib
	pandoc -o $(DRAFTNAME).docx --bibliography=bib.bib 0*md

clean:
	$(RM) $(DRAFTNAME).pdf $(DRAFTNAME).docx
