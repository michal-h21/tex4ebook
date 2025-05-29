Installation
------------

The stable version of `tex4ebook` is distributed by TeX distributions, it is included in both TeX Live and Miktex. 
A working \TeX\ distribution that includes [\TeX4ht](https://tug.org/tex4ht/) is required to run
`tex4ebook`, as it depends on \LaTeX\ and various programs and packages provided by \TeX\ distributions.
The development version may be installed using the following instructions.

> This package depends on
> [`make4ht`](https://github.com/michal-h21/make4ht#instalation) now, please
> install it first.
>
> It also depends on `tidy` and `zip` commands, both are available for Unix
> and Windows platforms, `zip` is distributed with TeX Live on Windows.
> You need [Pandoc](http://pandoc.org/) in order to make documentation.

On Unix systems, clone this repository to your disc and run command

    make
    make install

`tex4ebook` is installed to `/usr/local/bin` directory by default. The
directory can be changed by passing it's location to the `BIN_DIR` variable:

    make install BIN_DIR=~/.local/bin/

For Windows settings, see a 
[guide](https://d800fotos.wordpress.com/2015/01/19/create-e-books-from-latex-tex-files-ebook-aus-latex-tex-dateien-erstellen/) by Volker Gottwald.

If you want to produce ebooks for Amazon Kindle (MOBI, AZW and AZW3), you need
to install Kindlegen or Calibre.


