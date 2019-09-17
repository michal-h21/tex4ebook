tex_content = tex4ebook $(wildcard *.sty) $(wildcard *.4ht) $(wildcard *.tex) tidyconf.conf
lua_content = $(wildcard *.lua)
doc_file = tex4ebook-doc.pdf
TEXMFHOME = $(shell kpsewhich -var-value=TEXMFHOME)
INSTALL_DIR = $(TEXMFHOME)/tex/latex/tex4ebook
LUA_DIR = $(TEXMFHOME)/scripts/lua/tex4ebook
MANUAL_DIR = $(TEXMFHOME)/doc/latex/tex4ebook
BIN_DIR = /usr/local/bin
# expand the bin directory
SYSTEM_DIR = $(realpath $(BIN_DIR))
EXECUTABLE = $(SYSTEM_DIR)/tex4ebook
BUILD_DIR = build
BUILD_TEX4EBOOK = $(BUILD_DIR)/tex4ebook/
VERSION:= undefined
DATE:= undefined
ifeq ($(strip $(shell git rev-parse --is-inside-work-tree 2>/dev/null)),true)
	VERSION:= $(shell git --no-pager describe --abbrev=0 --tags --always )
	DATE:= $(firstword $(shell git --no-pager show --date=short --format="%ad" --name-only))
endif

# use sudo for install to a destination directory outside of $HOME
ifeq ($(findstring home,$(SYSTEM_DIR)),home)
	SUDO:=
else
	SUDO:=sudo
endif

ifeq ("$(wildcard $(EXECUTABLE))","")
	INSTALL_COMMAND:=$(SUDO) ln -s $(INSTALL_DIR)/tex4ebook $(EXECUTABLE)
else
	INSTALL_COMMAND:=
endif


all: doc

.PHONY: tags

tags:
ifeq ($(strip $(shell git rev-parse --is-inside-work-tree 2>/dev/null)),true)
	git fetch --tags
endif

doc: $(doc_file) readme.tex


tex4ebook-doc.pdf: tex4ebook-doc.tex readme.tex changelog.tex tags
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
	$(INSTALL_COMMAND)

