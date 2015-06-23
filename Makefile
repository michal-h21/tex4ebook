tex_content = $(wildcard *.sty) $(wildcard *.4ht) $(wildcard *.tex) $(wildcard *.lua)

all: doc

doc: tex4ebook-doc.pdf readme.tex

tex4ebook-doc.pdf: tex4ebook-doc.tex readme.tex changelog.tex
	latexmk -lualatex tex4ebook-doc.tex

readme.tex: README.md
	pandoc -f markdown+definition_lists -t LaTeX README.md > readme.tex

changelog.tex: CHANGELOG.md
	pandoc -f markdown+definition_lists -t LaTeX CHANGELOG.md > changelog.tex

build: doc
	rm -rf build
	mkdir build
	zip build/tex4ebook.zip $(tex_content)  README.md tex4ebook-doc.pdf
	#zip build/tex4ebook.zip *.sty *.4ht *.tex *.lua README.md tex4ebook-doc.pdf
