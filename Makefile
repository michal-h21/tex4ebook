tex_content = tex4ebook $(wildcard *.sty) $(wildcard *.4ht) $(wildcard *.tex) tidyconf.conf
lua_content = $(wildcard *.lua)
doc_file = tex4ebook-doc.pdf
TEXMFHOME = $(shell kpsewhich -var-value=TEXMFHOME)
INSTALL_DIR = $(TEXMFHOME)/tex/latex/tex4ebook
LUA_DIR = $(TEXMFHOME)/scripts/lua/tex4ebook
MANUAL_DIR = $(TEXMFHOME)/doc/latex/tex4ebook
SYSTEM_DIR = /usr/local/bin
BUILD_DIR = build
BUILD_TEX4EBOOK = $(BUILD_DIR)/tex4ebook/
VERSION:= $(shell git --no-pager describe --abbrev=0 --tags --always )

all: doc

doc: $(doc_file) readme.tex

tex4ebook-doc.pdf: tex4ebook-doc.tex readme.tex changelog.tex
	latexmk -pdf -pdflatex='lualatex "\def\version{${VERSION}}\def\gitdate{${DATE}}\input{%S}"' tex4ebook-doc.tex

readme.tex: README.md
	pandoc -f markdown+definition_lists+inline_notes+autolink_bare_uris -t LaTeX README.md > readme.tex

changelog.tex: CHANGELOG.md
	pandoc -f markdown+definition_lists -t LaTeX CHANGELOG.md > changelog.tex

build: doc $(tex_content) $(lua_content)
	@rm -rf build
	@mkdir -p $(BUILD_TEX4EBOOK)
	@cp $(tex_content) $(lua_content)  tex4ebook-doc.pdf $(BUILD_TEX4EBOOK)
	@cat tex4ebook | sed -e "s/{{version}}/${VERSION}/" >  $(BUILD_TEX4EBOOK)tex4ebook
	@cp README.md $(BUILD_TEX4EBOOK)README
	cd $(BUILD_DIR) && zip -r tex4ebook.zip tex4ebook

install: doc $(tex_content) $(lua_content)
	mkdir -p $(INSTALL_DIR)
	mkdir -p $(MANUAL_DIR)
	mkdir -p $(LUA_DIR)
	cp $(tex_content) $(INSTALL_DIR)
	cp $(lua_content) $(LUA_DIR)
	cp $(doc_file) $(MANUAL_DIR)
	chmod +x $(INSTALL_DIR)/tex4ebook
	ln -s $(INSTALL_DIR)/tex4ebook $(SYSTEM_DIR)/tex4ebook

