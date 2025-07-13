# Changes

- 2025/07/13

  - don't add dummy TOC to the OPF spine, to prevent Epubcheck error.

- 2025/07/12

  - added DAISY Schema.org Accessibility Metadata to Epub 3 (disable using the "daisy-" option)
  - added missing `xml:lang` attributes in metadata 
  - added ARIA `role` attributes for footnotes and TOC.

- 2025/04/14

  - version `0.4b` released.

- 2025/03/17

  - redefine `\title` and `\author` after the document class is loaded.
    https://github.com/michal-h21/tex4ebook/issues/138

- 2025/03/13

  - use `Make:autohlatex` for the default compilation mode. 

- 2025/02/19

  - version `0.4a` released.

- 2025/01/10

  - fixed adding of files for sections to the OPF file.

- 2024/12/03 

  - fixed Epub 3 footnotes.
    https://tex.stackexchange.com/a/732071/2891

- 2024/06/16

  - fixed support for `--build-dir` that contains dashes. Thanks to Danie-1.
    https://github.com/michal-h21/tex4ebook/pull/132

- 2024/04/21

  - better detection of `zip` and `miktex-zip` commands.

- 2024/02/23

  - version `0.4` released.

- 2023/10/30

  - added the `\epubpage` command

- 2023/10/17

  - added the `--build-dir` command line option.

- 2023/10/15

  - don't set PNG as image format explicitly.

- 2023/06/02

  - prevent fatal errors in the `zip` command executable detection.

- 2023/05/29

  - save author and date globally.

- 2023/05/23

  - removed spurious numbers from TOC in Epub 3.

- 2023/03/17

  - released version `0.3j`.
  - fixed bug in generating of TOC in the NCX file.

- 2023/03/02

  - released verision `0.3i`.
  - check if file with TOC exists before processing.

- 2023/01/12

  - added all mimetypes supported in Epub.

- 2023/01/09

  - fixed handling of metadata for filenames with accented characters.

- 2022/12/15

  - use lower case file extensions for mimetype matching. 

- 2022/12/01

  - set destinations for `\label` used inside of footnotes.
  - fixed handling of multiple tables of contents in Epub 3.

- 2022/11/20

  - added support for the `fn-in` option in the Epub 3 output.

- 2022/03/29

  - fixed support for \TeX\ filenames that contain dot.
  - removed spurious comma that was introduced earlier.
  
- 2022/03/28

  - documented the `no-cut` option.

- 2022/02/23

  - extended the documentation about build files.
  - deprecated the `--resolution` CLI argument.

- 2022/02/22

  - print `\subsubsection` in the Epub TOC.

- 2022/02/18

  - released version `0.3h`.

- 2022/01/13

  - fixed issue where child TOC elements were inserted into `<a>` element.

- 2021/12/07

  - print space after section number in Epub 3 TOC.
  - keep original elements in Epub 3 TOC.

- 2021/12/04

  - fixed support for 
    [appendix chapters in Epub 3](https://github.com/michal-h21/tex4ebook/issues/85).

- 2021/11/08

  - released version `0.3g`
  - bug fix: removed spurious `0` character from the NCX file.

- 2021/11/05

  - released version `0.3f`
  - fixed spurious numbers in NCX TOC caused by wrong use of `\cs_if_exist_use:cTF` 
    command.

- 2021/10/08

  - fix for `\author` support in `amsart` class.

- 2021/09/30
  - released version `0.3e`
  - better detection if `kindlegen` was found.

- 2021/09/23

  - use `ebook-convert` for convertsion to Kindle formats if `kindlegen` fails.

- 2021/08/22

  - fixed [cross-referencing issue](https://tex.stackexchange.com/a/611611/2891) 
    related to unnumbered equations.

- 2021/07/26

  - released version `0.3d`

- 2021/05/29

  - renamed `DeclareLanguage` to `\DeclareLanguageEbook`. 
    Fixes [issue 78](https://github.com/michal-h21/tex4ebook/issues/78).


- 2021/05/15

  - use `assert` in checking of existence of the `zip` command.
  - replace colons in `OPF` `id` attributes and add trailing `x` if the `id`
    starts with number. It should fix some validation issues.

- 2021/05/02

  - added more examples of configuration to the documentation.

- 2020/11/09
  
  - set exit status

- 2020/11/09

  - don't redefine `PicDisplay` configuration.

- 2020/11/06

  - bug fix: remove custom elements from the NCX file in the Epub 3 format.
  - released version `0.3c`

- 2020/09/07

  - released version `0.3b`

- 2020/08/26

  - fixed hiearchical structure in NCX TOC for chapters in backmatter and appendix
  - load `common_domfilters` extension by default.

- 2020/07/09

  - addded `AZW` and `AZW3` format support.

- 2020/06/21

  - save `\title` element
  - save contents of `\author` in macro directly

- 2020/06/15

  - remove child elements from elements that don't allow them in the OPF and NCX file.

- 2020/03/14

  - explicitly list supported section types in the NCX table

- 2019/11/01

  - released version `0.3a`
  - added `tex4ebook-` prefix to the output formats.
  - removed unused files.

- 2019/11/01

  - released version `0.3`   

- 2019/10/20

  - fixed the `TOC` cleanup in the `ePub 3` mode.
  - added support for the `page-spread-left` and `page-spreat-right` properties.

- 2019/10/20

  - addapted to use the `make4ht` logging mechanism.

- 2019/10/06

  - fixed bug with void elements parsing in the OPF file.
  - undo `\XeTeXcharclass` for the `:` character when the OPF file is generated.

- 2019/09/16

  - make the default build sequence before loading of the extensions. Some
    extensions need to modify the build sequence.

- 2019/08/28

  - added support for reading input from `STDIN`.

- 2019/08/27

  - added support for the `--jobname` command line option.

- 2019/08/25

  - use the `mkparams.get_args` function to retrieve the command line options

- 2019/07/24

  - added support for the `\author` command with an optional argument

- 2019/05/09

  - added support for the `\title` command with an optional argument

- 2019/04/04

  - register appendix chapters and section in the OPF file list
  - fixed handling of appendices in the NCX table of contents

- 2019/03/21

  - released version `0.2c`   

- 2019/03/07

  - use `Luatexbase` package in the documentation because of `Microtype` error
  - remove `<guide>` element even in ePub 2
  - added `encoding` attribute to XML declaration in the NCX and OPF files
  - clean the temporary directory (`filename-format`) before file packing

- 2019/01/21

  - added `\Configure{@author}`

- 2019/01/10

    - released version `0.2b`

- 28/11/2018

    - added support for appendix sections to the NCX file

- 27/11/2018

    - use the `uni-html4` option by default. It will convert some math characters as Unicode chars

- 13/11/2018

    - added --xetex option to the README

- 30/10/2018

    - use the original section numbering in TOC in the Epub 3 output. The numbering of the `<ol>` list is disabled by CSS.

- 18/10/2018

    - fixed the executable installation

- 03/09/2018

    - updated the `--help` message

- 30/08/2018

    - removed spurious `\NoFonts` command in the footnote configuration, it caused formating issues in the document following a footnote

- 22/06/2018

    - added support for the output directory selection

- 09/05/2018

    - added support for Polyglossia language codes
    - released version `0.2a`

- 03/05/2018

    - fixed output format handling

- 16/04/2018

    - don't run Git if the Makefile is executed outside of Git repo

- 09/04/2018

    - released version `0.2`

- 06/04/2018

    - documented the configuration file

- 02/03/2018

    - added support for `.tex4ebook` configuration file

- 28/02/2018

    - added media overlays handling

- 19/10/2017

    - added support for XeTeX

- 06/10/2017

    - added support for Make4ht extensions

- 27/04/2017 Version 0.1e

    - pack the accumulated changes for distribution
    - set version number from git tag

- 17/01/2017

    - process duplicate images only once
    - check the OPF table for duplicated id attributes

- 11/01/2017

    - pass `settings` table to the build file.

- 19/12/2016

    - new configuration: `\Configure{resettoclevels}{list of sectioning levels to be included in the NCX}`

- 31/10/2016

    - added tidyconf.conf to the Makefile

- 22/10/2016

    - added support for new Make4ht command `Make:add_file`

- 22/08/2016

    - fixed incorrect `<dc:creator>` generated by `\author`
    - clean ids in the OPF file if they contain invalid characters at the beginning

- 31/07/2016

    - use monospace font for command line options in order to prevent double
      hyphens to become dashes by ligaturing

- 22/07/2016

    - removed debugging message when `--lua` option is used

- 07/04/2016

    - Cut `\part` commands to standalone pages

- 05/04/2016 

    - bug fix: pages which contained math were arranged before other pages

- 31/03/2016 Version 0.1d 

    - bug fix: Unicode wasn't used by default 
    - bug fix: Formats weren't preserved


- 06/12/2015 Version 0.1c

    - added `--help` and `--version` command line options

- 25/11/2015

    - added missing language codes
    - added `\Configure{DocumentLanguage}` for the cases when document language inferencing doesn't work

- 17/11/2015

    - use mkparams for cli arguments handling. 
    - fixed inconsistencies between recent changes in make4ht and tex4ebook

- 24/09/2015 Version 0.1b

    - info about new workaround for `fontspec` package

- 25/08/2015

    - fatal error happened with epub3 when the document didn't contain the TOC

- 23/08/2015

    - simple cleaning of the ncx file if tidy command isn't available

- 05/07/2015 Version 0.1a

     - `tex4ebook` script was missing in the distribution zip file
     - all links moved to footnotes in the documentation

- 29/06/2015 Version 0.1

     - fixes in documentation

- 22/06/2015 

     - changes moved from README.md to CHANGELOG.md


- 18/06/2015 

     - replaced `--mathml` option with `--mode`. For `mathml` support, use`mathml` option for `tex4ht.sty`.
     - lot of stuff was fixed in `epub3` support. 
     - new command `\OpfAddProperty`  

- 14/01/2015 

      - thanks Volker Gottwald for guide on [installing and using
        tex4ebook](https://d800fotos.wordpress.com/2015/01/19/create-e-books-from-latex-tex-files-ebook-aus-latex-tex-dateien-erstellen/)
        on Windows

- 23/11/2014 

      - added new command `\OpfGuide`, for adding items to `<guide>`
        section in the `opf` file. This is useful for `epub` and `mobi` formats.

        Usage:

             \OpfGuide[filename]{title}{reference type}

         `filename` is optional, current file name is used when empty. See
         [epub 
         secrets](http://epubsecrets.com/where-do-you-start-an-epub-and-what-is-the-guide-section-of-the-opf-file.php)
         article

- 20/10/2014 

       - fixed issues with starred sections

       - files created with starred sectioning commands (`\chapter*`,
         `\section*`) should be included in correct reading order now

- 16/09/2014 

       - new features added
       - new configuration file for `--tidy` option, mathml and html5 elements
         are supported. This means that many validation errors in `mathml`
         output can be fixed with `--tidy` option
       - added configuration for all languages supported by `babel`
       - `woff` and `ttf` fonts are supported
       - added inline footlines in `epub3` format
       - added `no-cut` command line option for breaking sections and chapters
         into standalone pages
       - Please support [iniciative for improving mathml
         support](http://www.ulule.com/mathematics-ebooks/) in Gecko and Webkit
         engines. This will hopefully improve also Epub3 readers.

  

- 10/08/2013
  
       - [`make4ht`](https://github.com/michal-h21/make4ht) is now standalone
         application which `tex4ebook` depends on. You must [install
it](https://github.com/michal-h21/make4ht#instalation) 
         in order to use current `tex4ebook` version.
