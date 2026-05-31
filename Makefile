
DOCUMENT = main
AUX_DIR ?= aux

all: $(DOCUMENT).pdf

$(DOCUMENT).pdf : $(DOCUMENT).tex
	latexmk -pdf -pdflatex="pdflatex -synctex=1 -interaction=nonstopmode" --aux-directory=$(AUX_DIR) -use-make $(DOCUMENT).tex

clean:
	latexmk -c

distclean:
	latexmk -C

.PHONY: all clean distclean
