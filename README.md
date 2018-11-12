% [![Build Status](https://travis-ci.org/michal-h21/tex4ebook.svg?branch=master)](https://travis-ci.org/michal-h21/tex4ebook)

# Introduction

`TeX4ebook` is bundle of Lua scripts and `LaTeX` packages for conversion of
LaTeX files to ebook formats, for example `epub`, `mobi` and `epub3`. `tex4ht`
is used as conversion engine. 

Note that while `mobi` is supported by Amazon Kindle, most widespread ebook 
reader, it doesn't support `mathml` and this means that math must re represented
as images. The same is true for `epub`. This is not a good thing, especially 
for inline math, as you may experience wrong baselines. If your ebook contains
math, the only correct solution is to produce `epub3`, as it supports `mathml`.
The issue with `epub3` is, that majority of `e-ink` ebook readers doesn't 
support this format, reader applications exists mainly for Android and Apple 
devices. For books which contains mainly prose, all formats should be suitable,
but `epub3` supports most features from web standards, such as `CSS`. 

As with `tex4ht`, the emphasis is on conversion of document's logical structure
and metadata, basic visual appearance is preserved as well, but you should use
custom configurations if you want to make the document more visually appealing.
You can include custom `CSS` or fonts in configuration files.

## License

Permission is granted to copy, distribute and/or modify this software
under the terms of the LaTeX Project Public License, version 1.3.


# Usage


Run on the command line:

    tex4ebook [options] filename

You don't have to modify your source files unless you want to use commands
defined by `tex4ebook` in the document, or when your document uses a 
package which causes a compilation error. 

If you want to use `tex4ebook` commands, add this line to your document
preamble:

    \usepackage{tex4ebook}

But it is optional. You shouldn't need to modify your \TeX\ files

## Available commands

- `\coverimage{coverimage.name}` - include cover image to the document. 

# Command line options

`-c,--config`

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

`-e,--build-file (default nil)`  

:    Specify make4ht build file^[https://github.com/michal-h21/make4ht#build-file].
     Defaulf build file filename is `filename.mk4`, use this option if you use
     different filename.
  
`-f,--format (default epub)`

:    Output format. Epub, Epub3 and Mobi formats are supported.

`-l,--lua`

:    Runs htlualatex instead of htlatex.

`-m,--mode (default default)`

:    This set `mode` variable, accessible in the build file. Default supported
     values are `default` and `draft`. In `draft` mode, document is compiled
     only once, instead of three times.

`-r,--resolution`

:    Resolution of generated images, for example math. It should meet resolution
     of target devices, which is usually about 167 ppi.

`-s,--shell-escape`

:     Enable shell escape in htlatex run. This may be needed if you run external
      commands from your source files.

`-t,--tidy`

:     process output html files with `HTML tidy` command^[It needs to be installed separately].

`-v,--version`

:     print version number

 
# Configuration

`tex4ebook` uses `tex4ht`^[http://www.tug.org/tex4ht/] for conversion from LaTeX
to html. `tex4ht` is highly configurable using config files. Basic config file
structure is

    \Preamble{xhtml, comma separated list of options}
    ...
    \begin{document}
    ...
    \EndPreamble

Basic info about command configurations can be found in a 
work-in-progres *tex4ht tutorial*^[https://github.com/michal-h21/helpers4ht/wiki/tex4ht-tutorial], 
*tex4ht documentation*^[http://www.tug.org/applications/tex4ht/mn11.html], 
and in series of blogposts on CV Radhakrishnan's blog:
*Configure part 1*^[http://www.cvr.cc/?p=323], 
*Configure part 2*^[http://www.cvr.cc/?p=362], 
*Low level commands*^[http://www.cvr.cc/?p=482]. 
Available options for `\Preamble` command are listed in the article 
*TeX4ht: options*^[http://www.cvr.cc/?p=504]. *Comparison of tex4ebook and Pandoc output*^[https://github.com/richelbilderbeek/travis_tex_to_epub_example_1]

Great source of tips for `tex4ht` configuring is *tex4ht tag on TeX.sx*^[http://tex.stackexchange.com/questions/tagged/tex4ht], there is also a *tag for tex4ebook*^[http://tex.stackexchange.com/questions/tagged/tex4ebook].

Examples of interesting questions are 
*including images and fonts in ebooks*^[http://tex.stackexchange.com/a/213165/2891] 
or *setting image size in em units instead of pt*^[http://tex.stackexchange.com/a/195718/2891].

## Provided configurations

`tex4ebook` provides some configurations for your usage:

    \Configure{UniqueIdentifier}{identifier}


Every epub file should have unique identifier, like ISBN, DOI, URI etc. 
Default identifier is URI, with value `http://example.com/\jobname`.

    \Configure{OpfScheme}{URI}

Type of unique identifier, default type is URI. It is
used only in epub, it is deprecated for `epub3`

    \Configure{resettoclevels}{list of section types in descending order}

Configure section types which should be included in the `NCX` file. Default
value is the whole document hiearchy, from `\part` to `\paragraph`.

    \Configure{DocumentLanguage}{language code}

Each epub must declare the document language. It is inferred from `babel` main
language by default, but you can configure it when it doesn't work correctly.
The `language code` should be in [ISO
639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) form.

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

    \Configure{OpfMetadata}{item element}

Add item to `<metadata>` section in the `OPF` file.

    \Configure{OpfManifest}{maifest element}

Add item to `<manifest>` section in the `OPF` file.

    \Configure{xmlns}{prefix}{uri}

Add xml name space to `xhtml` files. Useful in `EPUB 3`



## Commands available in config files

`\OpfRegisterFile[filename]`

:    register file in the `OPF` file. Current output file is added by default.

`\OpfAddProperty{property type}`

:    add `EPUB3` property for the current file. See *EPUB3 spec*^[http://www.idpf.org/epub/301/spec/epub-publications.html#sec-item-property-values]

`\OpfGuide[filename]{title}{type}`

:    Add file to the `<guide>` section in the `OPF` file. See 
     *Where do you start an ePUB and what is the `<guide>` section of the `.OPF` file?*^[http://epubsecrets.com/where-do-you-start-an-epub-and-what-is-the-guide-section-of-the-opf-file.php]
     for some details. Note that `<guide>` is deprecated in `EPUB 3`.

## Build files

`tex4ebook` uses `make4ht`^[https://github.com/michal-h21/make4ht] as a build
system. See `make4ht` documentation for details on build files. 

## `.tex4ebook` configuration file

It is possible to globally modify the build settings using the configuration
file. New compilation commands can be added, extensions can be loaded or
disabled and settings can be set.

### Location

The configuration file can be saved either in
`$HOME/.config/tex4ebook/config.lua` or in `.tex4ebook` in the current directory or
it's parents (up to `$HOME`).

See the `make4ht` documentation for an example and more information.

# Troubleshooting

When compilation of the document breaks with error during `LaTeX` run, it may
be caused by some problem in `tex4ht` configuration. Comment out line
`\usepackage{tex4ebook}` in your source file and run command:

    htlatex filename 

if same error as in `tex4ebook` run arises, the problem is in some `tex4ht`
configuration. Try to identify the source of problem and if you cannot find the
solution, make minimal example showing the error and ask for help either on
*tex4ht mailing list*^[http://tug.org/mailman/listinfo/tex4ht] or on
*TeX.sx*^[http://tex.stackexchange.com/]. 

<!--
## Fontspec

`tex4ht` currently doesn't support `fontspec` and open type fonts. At this
moment, workaround for this is to modify your source file and conditionally
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

The drawback is that not all characters of the Unicode range are supported with
`inputenc`. For some solutions of this limitation, see a thread on *tex4ht
mailing list*^[http://tug.org/pipermail/tex4ht/2013q1/000719.html]

Other approach is to use `alternative4ht` package from [helpers4ht](https://github.com/michal-h21/helpers4ht)
bundle. It works only with Lua backend, but it supports full unicode and you 
don't have to use conditional package inclusion in your document. See 
an [example](http://michal-h21.github.io/samples/helpers4ht/fontspec.html).
-->

## Validation

In case of successful compilation, use command line tool `epubcheck`^[you need
to install it separately, see https://github.com/IDPF/epubcheck] to check
whether your document doesn't contain any errors.


Type 
 
    epubcheck filename.epub

### Common validation issues:

-  WARNING: filename.epub: item (OEBPS/foo.boo) exists in the zip file, but is
not declared in the OPF file

  Delete the `filename-(epub|epub3|mobi)` folder and `filename.epub`. Then
  run `tex4ebook` again.

- WARNING(ACC-009): hsmmt10t.epub/OEBPS/hsmmt10tch17.xhtml(235,15): 
MathML should either have an alt text attribute or annotation-xml child element.

  This is accessibility message. Unless you use some macro with annotations for
  each math instance, you will get lot of these messages. Try to use 
  `epubcheck -e` to print only serious errors.
