#no extension
DOCUMENT=manual

VIEWER=evince

TOPDF=pdflatex
OPTIONS=-file-line-error -interaction=nonstopmode

default: clean $(DOCUMENT).pdf

%.pdf: %.tex
	$(TOPDF) $(OPTIONS) $<

view: $(DOCUMENT).pdf
	$(VIEWER) $<

clean:
	#ignore if these files don't exist with -[command]
	-rm *.aux
	-rm *.dvi
	-rm *.log
	-rm *.pdf
