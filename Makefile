all: doc

doc: tex4ebook-doc.pdf readme.tex

tex4ebook-doc.pdf: tex4ebook-doc.tex readme.tex
	lualatex tex4ebook-doc.tex

readme.tex: README.md
	pandoc -f markdown+definition_lists -t LaTeX README.md > readme.tex

build: doc
	rm -rf build
	mkdir build
	zip build/tex4ebook.zip *.sty *.4ht *.tex *.lua README.md
