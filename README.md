Transrate: Quality assessment of de-novo transcriptome assemblies
===============

By:

- Richard Smith-Unna (@blahah404)
- Chris Boursnell (@chrisboursnell)
- Rob Patro
- Julian Hibberd
- Steven Kelly

### Description

This is the paper describing transrate (v1). The entire paper is written as a reproducible analysis software package that can be run on a unix system with a single command-line interface.

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

```bash
# get the paper code
$ git clone https://github.com/Blahah/transrate-paper.git
$ cd transrate-paper
# install a fresh ruby...
$ \curl -sSL https://get.rvm.io | bash -s stable --ruby
$ source ~/.rvm/scripts/rvm
# install dependencies
$ bundle install
$ transrate --install-deps all
```

#### Run

Now you can run the paper:

```bash
$ bundle exec bin/transrate-paper --help
```
