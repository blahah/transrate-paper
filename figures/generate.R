## Transrate paper, figure generation script

script.dir <- '~/code/transrate-paper/figures/'
# script.dir <- dirname(sys.frame()$ofile)
setwd(script.dir)

# load data for the figures
source('load_data.R')

# load helper functions
source('helper_functions.R')

# Figure 1 is a diagram of the transrate algorithm and was created by hand.
# All subsequent figures are generated from data using the code below

# Figure 2  is a diagram of different kinds of errors that occur during assembly
# and how they are detected in transrate

# Figure 3 breaks down the transrate score components, showing how they are
# distributed in each assembly and how they correlate with one another across
# assemblies.
source('figure_3/generate.R')

# Figure 4 shows Transrate contig score and RSEM-eval contig impact score
# plotted against reference-based accuracy for the simulated assemblies.
source('figure_4/generate.R')

# Figure 5 shows the distribution of contig scores for each species and
# assembler. It then steps through the assembly score construction process
# showing the mean contig score per assembly, the proportion of reads mapped per
# assembly, and the assembly score. Finally, it shows how much unique information
# each assembler provides.
source('figure_5/generate.R')

# Figure 6 shows the distribution of assembly scores for real assemblies
# retrieved from the NCBI Transcriptome Shotgun Archive.
source('figure_6/generate.R')

