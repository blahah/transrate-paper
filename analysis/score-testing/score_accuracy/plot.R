setwd('~/code/transrate-paper/analysis/score-testing/score_accuracy/')

library(ggplot2)

# first take a look at the blat of published transcriptome to genome
rice_t_g <- read.table('rice_transcriptome_genome.psl.tophits')
names(rice_t_g) <- c('name', 'qcov')
ggplot(rice_t_g, aes(x=qcov)) + geom_histogram()

load_scores <- function(score_path) {
  scores <- read.csv(score_path,
                     as.is=T)
  return(scores)
}

load_data <- function(blat_path, score_path) {
  # load blat output
  blat <- read.table(blat_path, header=T)
  names(blat) <- c("qName","blat")
  blat$qName <- as.character(blat$qName)
#
#   # load blast output
#   blast <- read.table(blast_path, header=T)
#   names(blast) <- c("qName", "id", "qCov")
#   blast$name <- as.character(blast$qName)
#   blast$blast <- blast$id * blast$qCov
#
#   # merge blast and blast
#   groundtruth <- merge(blat, blast[,c('qName', 'blast')], by='qName', all=T)
#   groundtruth$true <- (groundtruth$blat >= 0.95) | (groundtruth$blast >= 0.95)
  blat$true <- blat$blat >= 0.95

  # load transrate output
  score_data <- load_scores(score_path)

  # merge the two
  data <- merge(score_data, blat,
                by.x='contig_name', by.y='qName', all.x=T)
  data <- unique(data)
  data$true[is.na(data$true)] <- FALSE

  return(data)
}

bin_data <- function(data, species, assembler) {
  ## bin the scores by decile, count number of trues
  binned <- data[with(data, order(score)),]
  binned <- binned[!is.na(binned$score),]
  print(tail(binned))
  bin <- sapply(1:50, function(x) rep(x, nrow(binned)/50))
  dim(bin) <- NULL
  binned$bin <- c(bin, rep(50, nrow(binned) - length(bin)))
  library(plyr)
  binned_true <- ddply(binned[,c('true', 'bin')], .(bin), function(x) {
    t <- length(which(x$true == TRUE))
    f <- length(which(x$true == FALSE))
    tot <- t + f
    print(t)
    print(f)
    p_true <- t / tot
    names(p_true) <- NULL
    return(p_true)
  })
  names(binned_true)[2] <- 'prop_true'
  binned_true$species <- species
  binned_true$assembler <- assembler
  return(binned_true)
}

plot_binned <- function(data) {
  ggplot(data, aes(x=bin, y=prop_true)) +
    geom_bar(stat="identity", width=1) +
    ylim(0, 1) +
    facet_grid(assembler~species) +
    xlab("contig score decile") +
    ylab("proportion perfectly matching genome")
}

plot_roc <- function(data) {

}

### YEAST
## Trinity
yeast_trinity <- load_data('yeast_trinity_genome.psl.tophits',
  'trinity-Saccharomyces_cerevisiae.R64-1-1.75.pep.all.fa_Trinity.fasta_contigs.csv')
yeast_trinity_bin <- bin_data(yeast_trinity, 'yeast', 'trinity')

## Oases
yeast_oases <- load_data('yeast_oases_genome.psl.tophits',
 'oases-Saccharomyces_cerevisiae.R64-1-1.75.pep.all.fa_Oases.fasta_contigs.csv')
yeast_oases_bin <- bin_data(yeast_oases, 'yeast', 'oases')

### HUMAN
## Trinity
human_trinity <- load_data('human_trinity_genome.psl.tophits',
                           'trinity-Homo_sapiens.GRCh37.75.pep.all.fa_Trinity.fasta_contigs.csv')
human_trinity_bin <- bin_data(human_trinity, 'human', 'trinity')
## Oases


### RICE
## Trinity
rice_trinity <- load_data('rice_trinity_genome.psl.tophits',
                          'trinity-Osativa_204_protein.fa_Trinity.fasta_contigs.csv')
rice_trinity_bin <- bin_data(rice_trinity, 'rice', 'trinity')
## Oases
rice_oases <- load_data('rice_oases_genome.psl.tophits',
                        'oases-Saccharomyces_cerevisiae.R64-1-1.75.pep.all.fa_Oases.fasta_contigs.csv')
rice_oases_bin <- bin_data(rice_oases, 'rice', 'oases')

## SoapDenovoTrans
rice_soap <- load_data('rice_soap_genome.psl.tophits',
                       'soapdenovotrans-Osativa_204_protein.fa_soap.result.scafSeq_contigs.csv')
rice_soap_bin <- bin_data(rice_soap, 'rice', 'soap')

### Mousa
## Trinity
mouse_trinity <- load_data('mouse_trinity_genome.psl.tophits',
                           'trinity-Mus_musculus.NCBIM37.64.pep.all.fa_Trinity.fasta_contigs.csv')
mouse_trinity_bin <- bin_data(mouse_trinity, 'mouse', 'trinity')
## Oases
mouse_oases <- load_data('mouse_oases_genome.psl.tophits',
                         'oases-Mus_musculus.NCBIM37.64.pep.all.fa_transcripts.fa_contigs.csv')
mouse_oases_bin <- bin_data(mouse_oases, 'mouse', 'oases')
## SoapDenovoTrans
mouse_soap <- load_data('mouse_soap_genome.psl.tophits',
                        'soapdenovotrans-Mus_musculus.NCBIM37.64.pep.all.fa_soap.result.scafSeq_contigs.csv')
mouse_soap_bin <- bin_data(mouse_soap, 'mouse', 'soap')

plot_binned(rbind(yeast_trinity_bin, yeast_oases_bin,
                  human_trinity_bin,
                  mouse_trinity_bin, mouse_oases_bin, mouse_soap_bin,
                  rice_trinity_bin, rice_soap_bin))

# maxintrons
# human: 50kb
# mouse: 50kb
# rice: 20kb
# yeast: 10kb

# use published transcript sets to find optimal

# regenerate correlation plot including segmentation

# examine scores with and without the uniqueness measure

# examine the contribution of each component to the score
