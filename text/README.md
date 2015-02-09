transrate-paper
===============

## Commenting on the paper

Please make comments in one of the following ways:

1. In a separate text file.
2. Using Word track changes, after making a copy of the most recent .docx version of the manuscript.

Please name the file containing your comments with the following scheme: "INITIALS_comments_DATE.ext".

## Version control and archiving

The manuscript is written in text files (with Markdown, hence the `.md` extension). These files are version controlled using git and are stored on github with the rest of the manuscript's files.

When there are changes to the manuscript that are ready for comments, a new version of the .docx and .pdf files will be generated, prefixed with the date. Older versions of the .docx file, including comments, will be moved to the `archive` directory.

## Generating PDF and docx of the manuscript

Make sure you've got [pandoc](http://johnmacfarlane.net/pandoc/README.html) installed, then simply run from this directory:

```
make
```
