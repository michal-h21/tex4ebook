tex_content = $(wildcard *.sty) $(wildcard *.4ht) $(wildcard *.tex) $(wildcard *.lua)
doc_file = tex4ebook-doc.pdf
TEXMFHOME = $(shell kpsewhich -var-value=TEXMFHOME)
INSTALL_DIR = $(TEXMFHOME)/tex/latex/tex4ebook
MANUAL_DIR = $(TEXMFHOME)/doc/latex/tex4ebook

all: doc

doc: $(doc_file) readme.tex

tex4ebook-doc.pdf: tex4ebook-doc.tex readme.tex changelog.tex
	latexmk -lualatex tex4ebook-doc.tex

readme.tex: README.md
	pandoc -f markdown+definition_lists -t LaTeX README.md > readme.tex

changelog.tex: CHANGELOG.md
	pandoc -f markdown+definition_lists -t LaTeX CHANGELOG.md > changelog.tex

build: doc $(tex_content)
	@rm -rf build
	@mkdir build
	@zip build/tex4ebook.zip $(tex_content)  README.md tex4ebook-doc.pdf

install: doc $(tex_content)
	mkdir -p $(INSTALL_DIR)
	mkdir -p $(MANUAL_DIR)
	cp $(tex_content) $(INSTALL_DIR)
	cp $(doc_file) $(MANUAL_DIR)

