TeX4ebook
=========

`TeX4ebook` is bundle of lua scripts and `LaTeX` packages for conversion of LaTeX files to ebook formats, for example `epub`. 

Installation
------------

Clone this repository to `tex/latex/` directory in your local `texmf tree`. It's location can be found with command:

     kpsewhich -var-value TEXMFHOME

This package depends on `tidy` and `zip` commands, both are available for linux and windows platforms.


Usage
-----

Run on the command line:

    tex4ebook [options] filename

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

Output format. Currently, only `epub` is supported

*-i,--include-fonts*  

Include fonts in epub file. This may result in better rendering in ebook reader.

*-l,--lua*  

Runs htlualatex instead of htlatex. You may need to create `htlualatex` script.

*-r,--resolution* 

Resolution of generated images, for example math. It should meet resolution of target devices, which is usually about 167 ppi.

*-s,--shell-escape*  

Enable shell escape in htlatex run. This may be needed if you run external commands from your source files.

*-u,--utf8* 

If your sources are in utf8 encoding, you must use this option.
