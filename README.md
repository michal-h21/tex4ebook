TeX4ebook
=========

`TeX4ebook` is bundle of lua scripts and `LaTeX` packages for conversion of LaTeX files to ebook formats, for example `epub`. `tex4ht` is used as conversion engine. 

News
----

- 23/11/2014 added new command \OpfGuide, for adding items to `<guide>` section
  in the `opf` file. This is useful for `epub` and `mobi` formats. Usage:

    `\OpfGuide[filename]{title}{reference type}`

  `filename` is optional, current file name is used when empty. See 
  [epub secrets](http://epubsecrets.com/where-do-you-start-an-epub-and-what-is-the-guide-section-of-the-opf-file.php)
  article

- 20/10/2014 fixed issues with starred sections

  - files created by starred sectioning commands (`\chapter*`, `\section*`) should be included in normal reading order now

- 16/09/2014 new features added

  - new configuration file for `--tidy` option, mathml and html5 elements are 
    supported. This means that many validation errors in `mathml` output
    can be fixed with `--tidy` option
  - added configuration for all languages supported by `babel`
  - `woff` and `ttf` fonts are supported
  - added inline footlines in `epub3` format
  - added `no-cut` command line option for breaking sections and chapters into
    standalone pages



- Please support [iniciative for improving mathml support](http://www.ulule.com/mathematics-ebooks/) in Gecko and Webkit engines. This will hopefully improve also Epub3 
  readers.

  

- 10/08/2013
  [`make4ht`](https://github.com/michal-h21/make4ht) is now standalone application which `tex4ebook` depends on. You must [install it](https://github.com/michal-h21/make4ht#instalation) in order to use current `tex4ebook` version.

Installation
------------

> This package depends on [`make4ht`](https://github.com/michal-h21/make4ht#instalation) now, 
> please install it first.

Clone this repository to `tex/latex/` directory in your local `texmf tree`. It's location can be found with command:

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
     

This package depends on `tidy` and `zip` commands, both are available for linux and windows platforms.

Create script named `tex4ebook` or `tex4ebook.bat` on windows. 
It should run `texlua path/to/tex4ebook.lua` and pass all parameters there.
Sample script for UNIX-like systems, `tex4ebook` is provided. 
Place the script somewhere in the path so it can be called from the terminal.
On UNIX systems, you may try to call command:

    ln -s /full/path/to/tex4ebook /usr/local/bin/tex4ebook

(you may list directories in the path with command `echo $PATH`)

Usage
-----

Run on the command line:

    tex4ebook [options] filename

You don't have to modify your source file unless you want to use commands defined by `tex4ebook` in the document, or in the case your document uses some unsupported package like `fontspec` (see details bellow how to solve this issue).

If you want to use `tex4ebook` commands, add this line to your document preamble:

    \usepackage{tex4ebook}

### Available commands

- `\coverimage{coverimage.name}` - include cover image to the document. 

Options
-------

*-c,--config* 

This options enables you to provide custom configurations for `tex4ht`

### example

File sample.cfg


    \Preamble{xhtml}
    \CutAt{section}
    \begin{document}
    \EndPreamble

run 

    tex4ebook -c sample filename.tex

This config file will create `xhtml` file for every section. For bigger documents, this is recommended.
  
*-f,--format* (default epub) 

Output format. epub, epub3 and mobi are supported.

*-i,--include-fonts*  

Include fonts in epub file. This may result in better rendering in ebook reader.

*-l,--lua*  

Runs htlualatex instead of htlatex. You may need to create `htlualatex` script.

*-r,--resolution* 

Resolution of generated images, for example math. It should meet resolution of target devices, which is usually about 167 ppi.

*-s,--shell-escape*  

Enable shell escape in htlatex run. This may be needed if you run external commands from your source files.

*t,--tidy*

Run tidy on output html files.


Configuration
-------------

`tex4ebook` uses [tex4ht](http://www.tug.org/tex4ht/) for conversion from LaTeX to html. `tex4ht` is highly configurable using config files. Basic config file structure is

    \Preamble{xhtml, comma separated list of options}
    ...
    \begin{document}
    ...
    \EndPreamble

Basic info about command configurations can be found in 
[tex4ht documentation](http://www.tug.org/applications/tex4ht/mn11.html), 
and in series of blogposts on CV Radhakrishnan's blog 
[Configure part 1](http://www.cvr.cc/?p=323), 
[Configurepart 2](http://www.cvr.cc/?p=362), 
[Low level commands](http://www.cvr.cc/?p=482). 
Available options for `\Preamble` command are listed in the article 
[TeX4ht: options](http://www.cvr.cc/?p=504).

`tex4ebook` provides some configurations for your usage:

    \Configure{UniqueIdentifier}{identifier}


Every epub file should have unique identifier, like ISBN, DOI, URI etc. 
Default identifier is URI, with value `http://example.com/\jobname`.

    \Configure{OpfScheme}{ opf:scheme="URI"}

Type of unique identifier. It must be in form `opf:scheme="scheme type"`.

    \Configure{CoverImage}{before cover image}{after cover image}

By default, cover image is inserted in `<div class="cover-image">` element, 
you may use this configuration option to insert different markup, 
or even to place the cover image to standalone page.


    \Configure{CoverMimeType}{mime type of cover image}

Default value is `image/png`, change this value if you use other image 
type than `png`.


Troubleshooting
---------------

When compilation of the document breaks with error during `LaTeX` run, it may be caused by some problem in `tex4ht` configuration. Comment out line `\usepackage{tex4ebook}` in your source file and run command:

    htlatex filename 

if same error as in `tex4ebook` run arises, the problem is in some `tex4ht` configuration. Try to identify the source of problem and if you cannot find the solution, make minimal example showing the error and ask for help either on [tex4ht mailinglist](http://tug.org/mailman/listinfo/tex4ht) or on [TeX-sx](http://tex.stackexchange.com/). 

### Fontspec

`tex4ht` currently doesn't support `fontspec` and open type fonts. At this moment, workaround for this is to modify your source file and conditionaly include fontspec and any other conflicting packages only when document is not processed with `tex4ht`. 

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

Drawback is that not all characters of unicode range are supported with `inputenc`. For some solutions of this limitation, see thread on [tex4ht mailinglist](http://tug.org/pipermail/tex4ht/2013q1/000719.html)

### Validation

In case of successful compilation, use command line tool epubcheck to find if your document contains any error.

Type 
 
    epubcheck filename.epub

#### Common validation issues:

    WARNING: filename.epub: item (OEBPS/foo.boo) exists in the zip file, but is not declared in the OPF file

Delete the `filename-(epub|epub3|mobi)` folder and `filename.epub`. Then run `tex4ebook` again.


