# TeX4ebook

`TeX4ebook` is bundle of lua scripts and `LaTeX` packages for conversion of
LaTeX files to ebook formats, for example `epub`. `tex4ht` is used as
conversion engine. 


Installation
------------

> This package depends on [`make4ht`](https://github.com/michal-h21/make4ht#instalation) now, 
> please install it first.

Clone this repository to `tex/latex/` directory in your local `texmf tree`.
It's location can be found with command:

     kpsewhich -var-value TEXMFHOME

On `unix` systems, these commands could be used to install both `tex4ebook` and
`make4ht`:

    cd `kpsewhich -var-value TEXMFHOME`
    mkdir -p scripts/lua
    cd scripts/lua
    git clone https://github.com/michal-h21/make4ht
    cd `kpsewhich -var-value TEXMFHOME`
    mkdir -p tex/latex
    cd tex/latex
    git clone https://github.com/michal-h21/tex4ebook
     

This package depends on `tidy` and `zip` commands, both are available for Unix
and Windows platforms.

Create script named `tex4ebook` or `tex4ebook.bat` on windows. 
It should run `texlua path/to/tex4ebook.lua` and pass all parameters there.
Sample script for UNIX-like systems, `tex4ebook` is provided. 
Place the script somewhere in the path so it can be called from the terminal.
On UNIX systems, you may try to call command:


    chmod +x /full/path/to/tex4ebook
    ln -s /full/path/to/tex4ebook /usr/local/bin/tex4ebook

(you may list directories in the path with command `echo $PATH`)

For Windows settings, see a 
[guide](https://d800fotos.wordpress.com/2015/01/19/create-e-books-from-latex-tex-files-ebook-aus-latex-tex-dateien-erstellen/) by Volker Gottwald


Usage
-----

Run on the command line:

    tex4ebook [options] filename

You don't have to modify your source file unless you want to use commands
defined by `tex4ebook` in the document, or in the case your document uses some
unsupported package like `fontspec` (see details bellow how to solve this
issue).

If you want to use `tex4ebook` commands, add this line to your document
preamble:

    \usepackage{tex4ebook}

### Available commands

- `\coverimage{coverimage.name}` - include cover image to the document. 

Options
-------

-c,--config 

:    specify custom config file for `tex4ht`

   **example config file**: File `sample.cfg`
  
  
      \Preamble{xhtml}
      \CutAt{section}
      \begin{document}
      \EndPreamble
  
  run 
  
      tex4ebook -c sample filename.tex
  
  This config file will create `xhtml` file for every section. Note that this
  behaviour is default.

-e,--build-file (default nil)  

:    Specify [make4ht build file](https://github.com/michal-h21/make4ht#build-file).
     Defaulf build file filename is `filename.mk4`, use this option when it has
     different filename.
  
-f,--format (default epub) 

:    Output format. epub, epub3 and mobi are supported.

-l,--lua

:    Runs htlualatex instead of htlatex.

-m,--mode (default default)

:    This set `mode` variable, accessible in the build file. Default supported
     values are `default` and `draft`. In `draft` mode, document is compiled
     only once, instead of three times.

-r,--resolution 

:    Resolution of generated images, for example math. It should meet resolution
     of target devices, which is usually about 167 ppi.

-s,--shell-escape

:     Enable shell escape in htlatex run. This may be needed if you run external
      commands from your source files.

t,--tidy

:     Run tidy on output html files.


Configuration
-------------

`tex4ebook` uses [tex4ht](http://www.tug.org/tex4ht/) for conversion from LaTeX
to html. `tex4ht` is highly configurable using config files. Basic config file
structure is

    \Preamble{xhtml, comma separated list of options}
    ...
    \begin{document}
    ...
    \EndPreamble

Basic info about command configurations can be found in a work-in-progres 
[tex4ht tutorial](https://github.com/michal-h21/helpers4ht/wiki/tex4ht-tutorial)
, [tex4ht documentation](http://www.tug.org/applications/tex4ht/mn11.html), 
and in series of blogposts on CV Radhakrishnan's blog 
[Configure part 1](http://www.cvr.cc/?p=323), 
[Configurepart 2](http://www.cvr.cc/?p=362), 
[Low level commands](http://www.cvr.cc/?p=482). 
Available options for `\Preamble` command are listed in the article 
[TeX4ht: options](http://www.cvr.cc/?p=504).

Great source of tips for `tex4ht` configuring is [tex4ht tag on TeX.sx](http://tex.stackexchange.com/questions/tagged/tex4ht), there is also a [tag for tex4ebook](http://tex.stackexchange.com/questions/tagged/tex4ebook).

Interesting questions include [including images and fonts in ebooks](http://tex.stackexchange.com/questions/tagged/tex4ht) or [setting image size in em units instead of pt](http://tex.stackexchange.com/questions/tagged/tex4ht).

`tex4ebook` provides some configurations for your usage:

    \Configure{UniqueIdentifier}{identifier}


Every epub file should have unique identifier, like ISBN, DOI, URI etc. 
Default identifier is URI, with value `http://example.com/\jobname`.

    \Configure{OpfScheme}{URI"}

Type of unique identifier, default type is URI. It is
used only in epub, it is deprecated for `epub3`

    \Configure{CoverImage}{before cover image}{after cover image}

By default, cover image is inserted in `<div class="cover-image">` element, 
you may use this configuration option to insert different markup, 
or even to place the cover image to standalone page.


    \Configure{CoverMimeType}{mime type of cover image}

Default value is `image/png`, change this value if you use other image 
type than `png`.

If you don't want to include the cover image in the document, use command 

    \CoverMetadata{filename}

in the config file.


Troubleshooting
---------------

When compilation of the document breaks with error during `LaTeX` run, it may
be caused by some problem in `tex4ht` configuration. Comment out line
`\usepackage{tex4ebook}` in your source file and run command:

    htlatex filename 

if same error as in `tex4ebook` run arises, the problem is in some `tex4ht`
configuration. Try to identify the source of problem and if you cannot find the
solution, make minimal example showing the error and ask for help either on
[tex4ht mailinglist](http://tug.org/mailman/listinfo/tex4ht) or on
[TeX-sx](http://tex.stackexchange.com/). 

### Fontspec

`tex4ht` currently doesn't support `fontspec` and open type fonts. At this
moment, workaround for this is to modify your source file and conditionaly
include fontspec and any other conflicting packages only when document is not
processed with `tex4ht`. 

Sample:

    \documentclass{article}
    \makeatletter
    \@ifpackageloaded{tex4ht}{%
    % Packages for tex4ht unicode support
    \usepackage[utf8]{inputenc}
    \usepackage[T1]{fontenc}
    \usepackage[english,czech]{babel}
    }{%
    % Packages for xelatex
    \usepackage{fontspec}
    \usepackage{polyglossia}
    \setmainfont{Latin Modern Roman}
    }
    \makeatother

Drawback is that not all characters of unicode range are supported with
`inputenc`. For some solutions of this limitation, see thread on [tex4ht
mailinglist](http://tug.org/pipermail/tex4ht/2013q1/000719.html)

### Validation

In case of successful compilation, use command line tool epubcheck to find if
your document contains any error.

Type 
 
    epubcheck filename.epub

#### Common validation issues:

-  WARNING: filename.epub: item (OEBPS/foo.boo) exists in the zip file, but is
not declared in the OPF file

  Delete the `filename-(epub|epub3|mobi)` folder and `filename.epub`. Then
  run `tex4ebook` again.

- WARNING(ACC-009): hsmmt10t.epub/OEBPS/hsmmt10tch17.xhtml(235,15): MathML should either have an alt text attribute or annotation-xml child element.

  This is accessibility message. Unless you use some macro with annotations for
  each math instance, you will get lot of these messages. Try to use 
  `epubcheck -e` to print only serious errors.
