Transrate: Quality assessment of de-novo transcriptome assemblies
===============

By:

- Richard Smith-Unna (@blahah404)
- Chris Boursnell (@chrisboursnell)
- Rob Patro
- Julian Hibberd
- Steven Kelly

### Description

[NOTE: the paper app will not be released until the paper is submitted - so don't expect the instructions below to work until then!]

This is the paper describing transrate (v1). The entire paper is written as a reproducible analysis software package that can be run on a unix system with a single command.

The paper app will do the following:

- install any software dependencies it needs
- download all the data used in the analysis
- run the analysis pipelines
- generate figures from the analysis results
- compile the figures into the paper

### Instructions

#### System requirements

You need:

- a 64 bit unix operating system
- at least 20GB of RAM
- at least 1TB of hard disk space

#### Install

First you need to install the paper app. Choose one of the following:

**EITHER** If you already have Ruby installed, this command will install the transrate-paper app:

```bash
$ gem install transrate-paper
```

**OR** If you don't have Ruby yet, this command will install the latest Ruby and the transrate-paper app:

```bash
$ \curl -sSL https://get.rvm.io | bash -s stable --ruby --gems=transrate-paper
```

#### Run

Now you can run the paper:

```bash
$ transrate-paper
```
