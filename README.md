% [![Build Status](https://travis-ci.org/michal-h21/tex4ebook.svg?branch=master)](https://travis-ci.org/michal-h21/tex4ebook)

# Introduction

`TeX4ebook` is a tool for conversion from  \LaTeX\ to 
ebook formats, such as EPUB, MOBI and EPUB 3. 
It is based on `TeX4ht`^[https://tug.org/tex4ht/], 
which provides instructions for the actual \LaTeX\ to HTML conversion, 
and on `make4ht`^[https://ctan.org/pkg/make4ht?lang=en]. 


The conversion is focused on the logical structure of the converted document
and metadata. Basic visual appearance is preserved as well, but you should use
custom configurations if you want to make the document more visually appealing.
You can include custom `CSS` or fonts in a configuration file. 

`TeX4ebook` supports the same features as `make4ht`, in particular build files and extensions.
These may be used for post-processing of the generated HTML files, or to configure the image conversion.
See the `make4ht` documentation to see the supported features.


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

- `\coverimage[<graphicx options>]{coverimage.name}` - include cover image to
  the document. You can pass the same options as to `\includegraphics` command
  in the optional argument.

For example:

    \thispagestyle{empty}
    \begin{document}
    \coverimage[scale=0.8]{coverimage.name} % include scaled cover image
    ...
    \pagestyle{headings}

# Command line options

`-a,--loglevel` 

:      Set message log level. Possible values: debug, info, status, warning, error, fatal. Default: status.

`-c,--config`

:    specify custom config file for `TeX4ht`

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
     Default build file filename is `filename.mk4`, use this option if you use
     different filename.
  
`-f,--format (default epub)`

:    Output format. Possible values are `epub`, `epub3`, `mobi`, `azw` and `azw3`.

`-j,--jobname`

:    Specify the output file name, without file extension.

`-l,--lua`

:    Use LuaLaTeX as TeX engine.

`-m,--mode (default default)`

:    This set `mode` variable, accessible in the build file. Default supported
     values are `default` and `draft`. In `draft` mode, document is compiled
     only once, instead of three times.

`-s,--shell-escape`

:     Enable shell escape in the `htlatex` run. This is necessary for the execution of the external
      commands from your source files.

`-t,--tidy`

:     process output html files with `HTML tidy` command^[It needs to be installed separately].

`-x,--xetex`

:     Use xelatex for document compilation


`-v,--version`

:     Print the version number.
 
# Configuration

`TeX4ebook` uses `TeX4ht`^[http://www.tug.org/tex4ht/] for conversion from LaTeX
to html. `TeX4ht` is highly configurable using config files. Basic config file
structure is

    \Preamble{xhtml, comma separated list of options}
    ...
    \begin{document}
    ...
    \EndPreamble

Basic info about command configurations can be found in a 
work-in-progres *TeX4ht tutorial*^[https://github.com/michal-h21/helpers4ht/wiki/tex4ht-tutorial], 
*TeX4ht documentation*^[http://www.tug.org/applications/tex4ht/mn11.html], 
and in series of blogposts on CV Radhakrishnan's blog:
*Configure part 1*^[https://web.archive.org/web/20180908234227/http://www.cvr.cc/?p=323], 
*Configure part 2*^[https://web.archive.org/web/20180908201057/http://www.cvr.cc/?p=362], 
*Low level commands*^[https://web.archive.org/web/20180909101325/http://cvr.cc/?p=482]. 
Available options for `\Preamble` command are listed in the article 
*TeX4ht: options*^[https://web.archive.org/web/20180813043722/http://cvr.cc/?p=504]. *Comparison of tex4ebook and Pandoc output*^[https://github.com/richelbilderbeek/travis_tex_to_epub_example_1]

A great source of tips for `TeX4ht` configuration is *tex4ht tag on TeX.sx*^[http://tex.stackexchange.com/questions/tagged/tex4ht]. There is also a *tag for tex4ebook*^[http://tex.stackexchange.com/questions/tagged/tex4ebook].

Examples of interesting questions are 
*including images and fonts in ebooks*^[http://tex.stackexchange.com/a/213165/2891] 
or *setting image size in em units instead of pt*^[http://tex.stackexchange.com/a/195718/2891].

## Provided configurations

`tex4ebook` provides some configurations for your usage:

    \Configure{UniqueIdentifier}{identifier}


Every EPUB file should have unique identifier, like ISBN, DOI, URI etc. 
Default identifier is URI, with value `http://example.com/\jobname`.

    \Configure{@author}{\let\footnote\@gobble}

Local definitions of commands used in the `\author` command. As contents of
`\author` are used in XML files, it is necessary to strip away any information
which don't belongs here, such as `\footnote`.

    \Configure{OpfScheme}{URI}

Type of unique identifier, default type is URI. It is
used only in the EPUB format, it is deprecated for EPUB 3.

    \Configure{resettoclevels}{list of section types in descending order}

Configure section types which should be included in the `NCX` file. Default
value is the whole document hierarchy, from `\part` to `\paragraph`.

    \Configure{DocumentLanguage}{language code}

Each EPUB file must declare the document language. It is inferred from `babel` main
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

Add `XML` name space to the generated `XHTML` files. Useful in `EPUB 3`.


### Example config file

    \Preamble{xhtml}
    \begin{document}
    \Configure{DocumentLanguage}{de}
    % Use following lines if your document has ISBN:
    % \Configure{OpfScheme}{ISBN}
    % \Configure{UniqueIdentifier}{3-0000-1111-X}
    % Another possibility is URI that points for example to the ebook homepage:
    \Configure{OpfScheme}{URI}
    \Configure{UniqueIdentifier}
    {https://de.wikipedia.org/wiki/Der_achte_Sch&ouml;pfungstag}
    \Configure{CoverMimeType}{image/jpeg}
    % If you don't use \coverimage in the document text, 
    % add cover image using this command:
    \CoverMetadata{coverimage.jpg}
    % You can also add more authors to your ebook metadata:
    \Configure{OpfMetadata}
    {\HCode{<dc:publisher>Deutscher Bücherbund</dc:publisher>}}
    \Configure{OpfMetadata}
    {\HCode{<dc:contributor>Image Artist</dc:contributor>}}
    \Configure{OpfMetadata}
    {\HCode{<dc:contributor>Trans Lator</dc:contributor>}}
    \Configure{OpfMetadata}
    {\HCode{<dc:date opf:event='original-publication'>1888</dc:date>}}
    \EndPreamble

Remarks:

- Leading percent signs in the `.cfg` file introduce comments
- If the unique identifier is a URI which contains diacritical characters, the        
   equivalent HTML code needs to be inserted. `UTF8` is not recognized at that place.
- `UTF8` characters may be used in the `OpfMetadata` sections.

##  \TeX4ht options

\TeX4ht supports lot of options, that change produced HTML code without need to 
use configurations. Their list is available in the [\TeX4ht
documentation](https://www.kodymirus.cz/tex4ht-doc/texfourhtOptions.html).
You can pass options to `tex4ebook` in the argument that follows filename:

    tex4ebook filename.tex "option1,option2"

Alternatively, they can be put in the `\Preamble` command in the config file:

    \Preamble{xhtml,option1,option2}

### Options provided by `tex4ebook`

`no-cut`

:    By default `tex4ebook` splits document to separate HTML pages on `\chapter` command when it is available.
     Othervise, it splits on `\section`. This can be changed using the `\CutAt` command or numeric options, but 
     you need to use the `no-cut` option to prevent fatal error.

## Commands available in the config file

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
system. It provides support for build files written in Lua. These build files
can be used to call additional commands, like Bib\TeX\ or Makeindex, post-process
generated HTML files, change the way how images are created, or to modify
parameters of the conversion.  

Sample build file can look like this:

    if mode=="draft" then
      Make:htlatex {}
    else
      Make:htlatex {}
      Make:htlatex {}
      Make:htlatex {}
    end
    
    Make:image("png$",
    "dvipng -bg Transparent -T tight -o ${output} -D 170  -pp ${page} ${source}")

The `mode` variable holds value of the `--mode` argument to `tex4ebook`. The `draft` 
mode is used for  faster compilation, it calls LaTeX only once.

The `Make:image` function can configure handling of images created by extraction from the 
DVI file. It can be complex math, TikZ or PSTricks pictures, and so on. The `${<name>}` 
placeholders are filled by `tex4ebook` with parameters like current page number of 
the image DVI file, or output image name.

You can compile your document with a build file using the `-e` option:

    tex4ebook -m draft -e build.lua filename.tex

See `make4ht` documentation for more details on configuration files.

## `.tex4ebook` configuration file

`tex4ebook` supports a default build file, which is loaded automatically
without need to use the `-e` option.

### Location

The configuration file can be saved either in
`$HOME/.config/tex4ebook/config.lua` or in `.tex4ebook` in the current directory or
it's parents (up to `$HOME`).

See the `make4ht` documentation for an example and more information.

# Troubleshooting

## Kindle formats

`tex4ebook` uses `kindlegen` command for the conversion to Kindle formats (`mobi`,
`azw` and `azw3`). Unfortunatelly, Amazon discontinued this command, so we use
also `ebook-convert` provided by Calibre if `kindlegen` fails.


## Fixed layout EPUB

The basic support for the Fixed layout EPUB 3 can be enabled using the following configurations:

    \Configure{OpfMetadata}
    {\HCode{<meta property="rendition:layout">pre-paginated</meta>}}
    \Configure{OpfMetadata}
    {\HCode{<meta property="rendition:orientation">landscape</meta>}}
    \Configure{OpfMetadata}
    {\HCode{<meta property="rendition:spread">none</meta>}}
    \Configure{@HEAD}
    {\HCode{<meta name="viewport" content="width=1920, height=1080"/>\Hnewline}}

Modify the dimensions in the `<meta name="viewport>` element according to your needs. 

## Math issues

Note that while `mobi` is supported by Amazon Kindle, most widespread ebook 
reader, it doesn't support `MathML`. This means that math must be represented
as images. The same issue is true for the EPUB format as well. 
This is problematic especially for the inline math, as you may experience wrong 
vertical alignment of the math content and surrounding text. If your ebook contains
math, a better solution is to produce the `epub3` format, as it supports `MathML`.
The issue with EPUB 3 is that majority of `e-ink` ebook readers don't 
support it. Reader applications exists mainly for Android and Apple 
devices. For books which contains mainly prose, all formats should be suitable,
but EPUB 3 supports most features from web standards, such as `CSS`. 

## Compilation errors 

When compilation of the document breaks with error during `LaTeX` run, it may
be caused by some problem in `TeX4ht` configuration. Comment out line
`\usepackage{tex4ebook}` in your source file and run command:

    htlatex filename 

if same error as in `tex4ebook` run arises, the problem is in some `TeX4ht`
configuration. Try to identify the source of problem and if you cannot find the
solution, make minimal example showing the error and ask for help either on
*TeX4ht mailing list*^[http://tug.org/mailman/listinfo/tex4ht] or on
*TeX.sx*^[http://tex.stackexchange.com/]. 

## Validation

In case of successful compilation, use command line tool `epubcheck`^[you need
to install it separately, see https://github.com/IDPF/epubcheck] to check
whether your document doesn't contain any errors.


Type 
 
    epubcheck filename.epub

### Common validation issues:

-  WARNING: filename.epub: item (OEBPS/foo.boo) exists in the zip file, but is
not declared in the OPF file

  Delete the `filename-(epub|epub3|mobi|azw|azw3)` folder and `filename.epub`. Then
  run `tex4ebook` again.

- WARNING(ACC-009): hsmmt10t.epub/OEBPS/hsmmt10tch17.xhtml(235,15): 
MathML should either have an alt text attribute or annotation-xml child element.

  This is accessibility message. Unless you use some macro with annotations for
  each math instance, you will get lot of these messages. Try to use 
  `epubcheck -e` to print only serious errors.
