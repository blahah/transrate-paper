## Transrate paper, figure generation script

setwd('~/code/transrate-paper/figures/')

# load data for the figures
source('load_data.R')

# load helper functions
source('helper_functions.R')

# Figure 1 is a diagram of the transrate algorithm and was created by hand.
# All subsequent figures are generated from data using the code below

# Figure 2 breaks down the transrate score components, showing how they are
# distributed in each assembly and how they correlate with one another across
# assemblies.
source('figure_2/generate.R')

# Figure 3 shows the distribution of contig scores for each species and
# assembler, as well as the number of contigs in each assembly with
# a score > 0.5
source('figure_3/generate.R')

# Figure 4 demonstrates that the transrate score accurately predicts whether
# a contig is well-assembled. This figure is a single-panel with a facet grid
# of histograms showing, for each assembly, the proportion of contigs in each
# score decile that accurately reconsruct a reference transcript.
source('figure_4/generate.R')

# Figure 5 demonstrates that the transrate contig score is independent of
# contig length and expression. This figure is composed of two panels, showing
# the distribution of contig score with (a) contig length and (b) expression
# level.
source('figure_5/generate.R')

# Figure 6 shows the distribution of assembly scores for real assemblies
# retrieved from the NCBI Transcriptome Shotgun Archive. This figure is
# composed of 4 panels:
# a. the full distribution of assembly scores
# b. distribution per clade for clades with >= 10 assemblies
# c. distribution per assembler for assemblers with >= 10 assemblies
# d. assembly score plotted against read length with a linear model + 95% CI
source('figure_6/generate.R')

