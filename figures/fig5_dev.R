setwd('/Users/rds45/code/transrate-paper/data/crbb_txome')

library(ggplot2)

cols <- c('query', 'target', 'id', 'alnlen', 'mismatches', 'gaps',
          'qstart', 'qend', 'tstart', 'tend', 'evalue', 'bitscore',
          'qlen', 'tlen')

load_data <- function(blast, transrate, sp, assembler) {
  library(dplyr)
  df <- read.table(blast)
  names(df) <- cols
  df$tcov <- df$alnlen / df$tlen
  df$refscore = df$id * df$tcov / 100
  df <- group_by(df, query)
  df <- do(df, (function(x) {
    return(x[with(x, order(-refscore)),][1,])
  })(.))
  df_ts <- read.csv(transrate)
  df <- merge(df[,c('query', 'target', 'id', 'evalue', 'bitscore', 'tcov', 'refscore')],
                        df_ts[,c('contig_name', 'score', 'length', 'p_good',
                                 'p_bases_covered', 'p_seq_true',
                                 'p_unique', 'p_not_segmented', 'eff_length',
                                 'eff_count')],
                        by.x = 'query',
                        by.y = 'contig_name')
  df$sp <- sp
  df$assembler <- assembler
  df$bin <- round(df$score, 1)
  df$true <- df$refscore >= 0.5
  if (nrow(df[df$length <= 200,]) > 0) {
    df[df$length <= 200,]$score <- 0.01
  }
  return(df)
}

bin_data <- function(data, species, assembler) {
  ## bin the scores by decile, count number of trues
  n_bins <- 10
  binned <- data[with(data, order(score)),]
  binned <- binned[!is.na(binned$score),]
  bin <- sapply(1:n_bins, function(x) rep(x, nrow(binned)/n_bins))
  dim(bin) <- NULL
  binned$bin <- c(bin, rep(n_bins, nrow(binned) - length(bin)))
  library(plyr)
  binned_true <- ddply(binned[,c('true', 'bin')], .(bin), function(x) {
    t <- length(which(x$true == TRUE))
    f <- length(which(x$true == FALSE))
    tot <- t + f
    p_true <- t / tot
    names(p_true) <- NULL
    return(p_true)
  })
  names(binned_true)[2] <- 'prop_true'
  binned_true$species <- species
  binned_true$assembler <- assembler
  return(binned_true)
}

bin_by_interval <- function(data, species, assembler) {
  binned <- data[with(data, order(score)),]
  binned <- binned[!is.na(binned$score),]
  library(plyr)
  binned_true <- ddply(binned[,c('true', 'bin')], .(bin), function(x) {
    t <- length(which(x$true == TRUE))
    f <- length(which(x$true == FALSE))
    tot <- t + f
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

# RICE

rice_trinity <- load_data('rice/trinity/transcripts_into_Osativa_204_transcript.1.blast',
                          '../trinity-Osativa_204_protein.fa_Trinity.fasta_contigs.csv',
                          'rice', 'trinity')
rice_trinity_binned <- bin_data(rice_trinity, 'rice', 'trinity')
rice_trinity_intbin <- bin_by_interval(rice_trinity, 'rice', 'trinity')

rice_oases <- load_data('rice/oases/transcripts_into_Osativa_204_transcript.1.blast',
                         '../oases-Osativa_204_protein.fa_transcripts.fa_contigs.csv',
                         'rice', 'oases')
rice_oases_binned <- bin_data(rice_oases, 'rice', 'oases')
rice_oases_intbin <- bin_by_interval(rice_oases, 'rice', 'oases')

rice_soap <- load_data('rice/soap/transcripts_into_Osativa_204_transcript.1.blast',
                       '../soapdenovotrans-Osativa_204_protein.fa_soap.result.scafSeq_contigs.csv',
                       'rice', 'soap')
rice_soap_binned <- bin_data(rice_soap, 'rice', 'soap')
rice_soap_intbin <- bin_by_interval(rice_soap, 'rice', 'soap')

rice <- rbind(rice_trinity, rice_oases, rice_soap)
rice_binned <- rbind(rice_trinity_binned, rice_oases_binned, rice_soap_binned)
rice_intbin <- rbind(rice_trinity_intbin, rice_oases_intbin, rice_soap_intbin)

# MOUSE

mouse_trinity <- load_data('mouse/trinity/transcripts_into_Mus_musculus.GRCm38.cdna_all_plus_ncrna.1.blast',
                           '../trinity-Mus_musculus.NCBIM37.64.pep.all.fa_Trinity.fasta_contigs.csv',
                           'mouse', 'trinity')
mouse_trinity_binned <- bin_data(mouse_trinity, 'mouse', 'trinity')
mouse_trinity_intbin <- bin_by_interval(mouse_trinity, 'mouse', 'trinity')

mouse_oases <- load_data('mouse/oases/transcripts_into_Mus_musculus.GRCm38.cdna_all_plus_ncrna.1.blast',
                           '../oases-Mus_musculus.NCBIM37.64.pep.all.fa_transcripts.fa_contigs.csv',
                           'mouse', 'oases')
mouse_oases_binned <- bin_data(mouse_oases, 'mouse', 'oases')
mouse_oases_intbin <- bin_by_interval(mouse_oases, 'mouse', 'oases')

mouse_soap <- load_data('mouse/soap/transcripts_into_Mus_musculus.GRCm38.cdna_all_plus_ncrna.1.blast',
                           '../soapdenovotrans-Mus_musculus.NCBIM37.64.pep.all.fa_soap.result.scafSeq_contigs.csv',
                           'mouse', 'soap')
mouse_soap_binned <- bin_data(mouse_soap, 'mouse', 'soap')
mouse_soap_intbin <- bin_by_interval(mouse_soap, 'mouse', 'soap')

mouse <- rbind(mouse_trinity, mouse_oases, mouse_soap)
mouse_binned <- rbind(mouse_trinity_binned, mouse_oases_binned, mouse_soap_binned)
mouse_intbin <- rbind(mouse_trinity_intbin, mouse_oases_intbin, mouse_soap_intbin)

# HUMAN

human_trinity <- load_data('human/trinity/Trinity_into_Homo_sapiens.GRCh38.cdna_all_plus_ncrna.1.blast',
                           '../trinity-Homo_sapiens.GRCh37.75.pep.all.fa_Trinity.fasta_contigs.csv',
                           'human', 'trinity')
human_trinity_binned <- bin_data(human_trinity, 'human', 'trinity')
human_trinity_intbin <- bin_by_interval(human_trinity, 'human', 'trinity')

human_oases <- load_data('human/oases/Homo_sapiens.GRCh38.cdna_all_plus_ncrna_into_Oases.2.blast',
                         '../oases-',
                         'human', 'oases')
human_oases_binned <- bin_data(human_oases, 'human', 'oases')
human_oases_intbin <- bin_by_interval(human_oases, 'human', 'oases')

# YEAST

yeast_trinity <- load_data('yeast/trinity/Trinity_into_Saccharomyces_cerevisiae.R64-1-1.cdna_all_plus_ncrna.1.blast',
                           '../trinity-Saccharomyces_cerevisiae.R64-1-1.75.pep.all.fa_Trinity.fasta_contigs.csv',
                           'yeast', 'trinity')
yeast_trinity_binned <- bin_data(yeast_trinity, 'yeast', 'trinity')
yeast_trinity_intbin <- bin_by_interval(yeast_trinity, 'yeast', 'trinity')

yeast_oases <- load_data('yeast/oases/Oases_into_Saccharomyces_cerevisiae.R64-1-1.cdna_all_plus_ncrna.1.blast',
                         '../oases-Saccharomyces_cerevisiae.R64-1-1.75.pep.all.fa_Oases.fasta_contigs.csv',
                         'yeast', 'oases')
yeast_oases_binned <- bin_data(yeast_oases, 'yeast', 'oases')
yeast_oases_intbin <- bin_by_interval(yeast_oases, 'yeast', 'oases')

yeast_intbin <- rbind(yeast_trinity_intbin, yeast_oases_intbin)

# PLOTS
ggplot(rbind(rice, mouse), aes(x=bin, y=refscore, group=bin)) +
  geom_boxplot() +
  facet_grid(sp ~ assembler)

plot_binned(rbind(rice_binned, mouse_binned))

ggplot(rbind(rice_intbin, mouse_intbin, yeast_intbin),
       aes(x=bin, y=prop_true)) +
  geom_bar(stat="identity") +
  facet_grid(species ~ assembler)
