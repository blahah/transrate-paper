# Transrate paper - figure 4

data_dir <- '../data'

library(ggplot2)
library(data.table)

spp <- c('mouse', 'rice', 'human', 'yeast')
assem <- c('oases', 'trinity', 'soap')

cols <- c('contig_name', 'target', 'id', 'alnlen', 'mismatches', 'gaps',
          'qstart', 'qend', 'tstart', 'tend', 'evalue', 'bitscore',
          'qlen', 'tlen')

load_data <- function(blast, transrate, species, assem, keepall=FALSE) {
  library(dplyr)
  dt <- fread(paste(data_dir, blast, sep="/"))
  setnames(dt, cols)
  setkey(dt, contig_name)
  dt[, tcov:=alnlen/tlen]
  dt[, qcov:=alnlen/qlen]
  dt[, refscore:=id * tcov * qcov / 100]
  dt <- group_by(dt, contig_name) %>% top_n(n=1, wt=refscore)
  dt_ts <- fread(paste(data_dir, transrate, sep="/"))
  setkey(dt_ts, contig_name)
  dt <- merge(as.data.frame(dt_ts[,c('contig_name', 'score', 'length', 'p_good',
                       'p_bases_covered', 'p_seq_true',
                       'p_unique', 'p_not_segmented', 'eff_length',
                       'eff_count'),
                    with=FALSE]),
              as.data.frame(dt[, c('contig_name', 'target', 'id', 'evalue', 'bitscore',
                     'tcov', 'qcov', 'refscore'),
                 with=FALSE]),
              all.x=keepall)
  dt <- as.data.table(dt)
  dt[, sp:=species]
  dt[, assembler:=assem]
  dt[, score:=as.numeric(score)]
  dt[is.na(refscore), refscore:=0]
  dt[, bin:=round(score, 1)]
  dt[, true:=refscore >= 0.5]

  return(dt)
}

get_p_true <- function(x) {
  t <- length(which(x == TRUE))
  f <- length(which(x == FALSE))
  tot <- t + f
  p_true <- t / tot
  names(p_true) <- NULL
  return(p_true)
}

bin_data <- function(data, species, assembler) {
  ## bin the scores by decile, count number of trues
  n_bins <- 10
  setkey(data, score)
  binned <- data[!is.na(score),]
  bin <- sapply(1:n_bins, function(x) rep(x, nrow(binned)/n_bins))
  dim(bin) <- NULL
  bin <- c(bin, rep(n_bins, nrow(binned) - length(bin)))
  binned$bin <- bin
  binned <- group_by(binned, bin)
  binned_true <- summarise(binned, prop_true=get_p_true(true))
  binned_true[, species:=species]
  binned_true[, assembler:=assembler]
  return(binned_true)
}

plot_binned <- function(data) {
  p <- ggplot(data, aes(x=bin, y=prop_true)) +
    geom_bar(stat="identity", width=0.9) +
#     ylim(0, 1) +
    facet_grid(species~assembler) +
    scale_x_continuous(breaks=1:10) +
    xlab("contig score decile") +
    ylab("proportion matching reference transriptome") +
    theme_bw()
  return(p)
}

mcc <- function(FP, FN, TP, TN) {
  return(
    (TP * TN - FP * FN) / sqrt((TP + FP)*(TP + FN)*(TN + FP)*(TN + FN))
  )
}

accuracy <- function(dt, cutoff=0.5, refcutoff=0.5) {
  est <- dt$score >= cutoff
  truth <- dt$refscore >= refcutoff
  clas <- rep(4, length(est))
  clas[est & truth] <- 1
  clas[est & !truth] <- 2
  clas[!est & truth] <- 3
  clas <- factor(clas)
  levels(clas) <- c('TP', 'FP', 'FN', 'TN')
  tab <- table(clas)
  FN <- as.numeric(tab[['FN']])
  FP <- as.numeric(tab[['FP']])
  TN <- as.numeric(tab[['TN']])
  TP <- as.numeric(tab[['TP']])
  P <- TP + FN
  N <- FP + TN
  return(list(
    fn = FN,
    fp = FP,
    tn = TN,
    tp = TP,
    sensitivity = TP / P,
    specificity = TN / N,
    precision = TP / (TP + FP),
    npv = TN / (TN + FN),
    fpr = FP/ N,
    fdr = FP / (FP + TP),
    fnr = FN / (FN + TP),
    accuracy = (TP + TN) / (P + N),
    f1 = 2*TP  / (2*TP + FP + FN),
    mcc = mcc(FP, FN, TP, TN)
  ))
}

acc_sweep <- function(dt, species, assembler) {
  df <- NULL
  for (cutoff in seq(0.1, 0.9, 0.1)) {
    for (refcutoff in seq(0.1, 0.9, 0.1)) {
        acc <- accuracy(dt, cutoff, refcutoff)
      if (is.null(df)) {
        df <- data.frame(cutoff, refcutoff, acc)
      } else {
        df <- rbind(df, data.frame(cutoff, refcutoff, acc))
      }
    }
  }
  df$species <- species
  df$assembler <- assembler
  df
}

plot_acc <- function(dt) {
  p <- ggplot(dt, aes(x=specificity, y=sensitivity, colour=assembler, pch=species)) +
    geom_point(size=10) + xlim(0, 1) + ylim(0, 1)
  return(p)
}

do_cor <- function(df, species, assembler) {
  res <- cor(df$score, df$refscore, method="spearman")
  return(data.frame(species, assembler, cor=res))
}

# RICE

rice_trinity <- load_data(
  'crbb_txome/rice/trinity/transcripts_into_Osativa_204_transcript.1.blast',
  'rice/transrate/trinity/rice-trinity_Trinity.fasta_contigs.csv',
  'rice', 'trinity')
rice_trinity$true <- rice_trinity$refscore >= 0.5
rice_trinity_binned <- bin_data(rice_trinity, 'rice', 'trinity')
rice_trinity_acc <- acc_sweep(rice_trinity, 'rice', 'trinity')
rice_trinity_cor <- do_cor(rice_trinity, 'rice', 'trinity')

rice_oases <- load_data(
  'crbb_txome/rice/oases/transcripts_into_Osativa_204_transcript.1.blast',
  'rice/transrate/oases/rice-oases_transcripts.fa_contigs.csv',
  'rice', 'oases')
rice_oases_binned <- bin_data(rice_oases, 'rice', 'oases')
rice_oases_acc <- acc_sweep(rice_oases, 'rice', 'oases')
rice_oases_cor <- do_cor(rice_oases, 'rice', 'oases')

rice_soap <- load_data(
  'crbb_txome/rice/soap/transcripts_into_Osativa_204_transcript.1.blast',
  'rice/transrate/soapdenovotrans/rice-soapdenovotrans_soap.result.scafSeq_contigs.csv',
  'rice', 'soap')
rice_soap_binned <- bin_data(rice_soap, 'rice', 'soap')
rice_soap_acc <- acc_sweep(rice_soap, 'rice', 'soap')
rice_soap_cor <- do_cor(rice_soap, 'rice', 'soap')

rice <- rbind(rice_trinity, rice_oases, rice_soap)
rice_binned <- rbind(rice_trinity_binned, rice_oases_binned, rice_soap_binned)
rice_acc <- rbind(rice_trinity_acc, rice_oases_acc, rice_soap_acc)
rice_acc_l <- melt(rice_acc, id=c('species', 'assembler', 'cutoff', 'refcutoff',
                                    'fp', 'fn', 'tp', 'tn'))
rice_cor <- rbind(rice_trinity_cor, rice_oases_cor, rice_soap_cor)

# MOUSE

mouse_trinity <- load_data(
  'crbb_txome/mouse/trinity/transcripts_into_Mus_musculus.GRCm38.cdna_all_plus_ncrna.1.blast',
  'mouse/transrate/trinity/mouse-trinity_Trinity.fasta_contigs.csv',
  'mouse', 'trinity')
mouse_trinity_binned <- bin_data(mouse_trinity, 'mouse', 'trinity')
mouse_trinity_acc <- acc_sweep(mouse_trinity, 'mouse', 'trinity')
mouse_trinity_cor <- do_cor(mouse_trinity, 'mouse', 'trinity')

mouse_oases <- load_data(
  'crbb_txome/mouse/oases/transcripts_into_Mus_musculus.GRCm38.cdna_all_plus_ncrna.1.blast',
  'mouse/transrate/oases/mouse-oases_transcripts.fa_contigs.csv',
  'mouse', 'oases')
mouse_oases_binned <- bin_data(mouse_oases, 'mouse', 'oases')
mouse_oases_acc <- acc_sweep(mouse_oases, 'mouse', 'oases')
mouse_oases_cor <- do_cor(mouse_oases, 'mouse', 'oases')

mouse_soap <- load_data(
  'crbb_txome/mouse/soap/transcripts_into_Mus_musculus.GRCm38.cdna_all_plus_ncrna.1.blast',
  'mouse/transrate/soapdenovotrans/mouse-soapdenovotrans_soap.result.scafSeq_contigs.csv',
  'mouse', 'soap')
mouse_soap_binned <- bin_data(mouse_soap, 'mouse', 'soap')
mouse_soap_acc <- acc_sweep(mouse_soap, 'mouse', 'soap')
mouse_soap_cor <- do_cor(mouse_soap, 'mouse', 'soap')

mouse <- rbind(mouse_trinity, mouse_oases, mouse_soap)
mouse_binned <- rbind(mouse_trinity_binned, mouse_oases_binned, mouse_soap_binned)
mouse_acc <- rbind(mouse_trinity_acc, mouse_oases_acc, mouse_soap_acc)
mouse_cor <- rbind(mouse_trinity_cor, mouse_oases_cor, mouse_soap_cor)

# HUMAN

human_trinity <- load_data(
  'crbb_txome/human/trinity/Trinity_into_Homo_sapiens.GRCh38.cdna_all_plus_ncrna.1.blast',
  'human/transrate/trinity/human-trinity_Trinity.fasta_contigs.csv',
  'human', 'trinity')
human_trinity_binned <- bin_data(human_trinity, 'human', 'trinity')
human_trinity_acc <- acc_sweep(human_trinity, 'human', 'trinity')
human_trinity_cor <- do_cor(human_trinity, 'human', 'trinity')

human_oases <- load_data(
  'crbb_txome/human/oases/Oases_into_Homo_sapiens.GRCh38.cdna_all_plus_ncrna.1.blast',
  'human/transrate/oases/human-oases_Oases.fasta_contigs.csv',
  'human', 'oases')
human_oases_binned <- bin_data(human_oases, 'human', 'oases')
human_oases_acc <- acc_sweep(human_oases, 'human', 'oases')
human_oases_cor <- do_cor(human_oases, 'human', 'oases')

human <- rbind(human_trinity, human_oases)
human_binned <- rbind(human_trinity_binned, human_oases_binned)
human_acc <- rbind(human_trinity_acc, human_oases_acc)

# YEAST

yeast_trinity <- load_data(
  'crbb_txome/yeast/trinity/Trinity_into_Saccharomyces_cerevisiae.R64-1-1.cdna_all_plus_ncrna.1.blast',
  'yeast/transrate/trinity/yeast-trinity_Trinity.fasta_contigs.csv',
  'yeast', 'trinity')
yeast_trinity_binned <- bin_data(yeast_trinity, 'yeast', 'trinity')
yeast_trinity_acc <- acc_sweep(yeast_trinity, 'yeast', 'trinity')

yeast_oases <- load_data(
  'crbb_txome/yeast/oases/Oases_into_Saccharomyces_cerevisiae.R64-1-1.cdna_all_plus_ncrna.1.blast',
  'yeast/transrate/oases/yeast-oases_Oases.fasta_contigs.csv',
  'yeast', 'oases')
yeast_oases_binned <- bin_data(yeast_oases, 'yeast', 'oases')
yeast_oases_acc <- acc_sweep(yeast_oases, 'yeast', 'oases')

yeast <- rbind(yeast_trinity, yeast_oases)
yeast_binned <- rbind(yeast_trinity_binned, yeast_oases_binned)
yeast_acc <- rbind(yeast_trinity_acc, yeast_oases_acc)

# BINNED CLASSIFICATION PLOT
all_binned <- as.data.frame(rbind(rice_binned, mouse_binned, human_binned, yeast_binned))
all_binned$species <- factor(all_binned$species, levels=spp)
all_binned$assembler <- factor(all_binned$assembler, levels=assem)
fig4a <- plot_binned(all_binned) +
  theme(legend.key = element_blank())

# ROC PLOT
all_acc <- rbind(rice_acc, mouse_acc, human_acc, yeast_acc)
all_acc$species <- factor(all_acc$species, levels=spp)
all_acc$assembler <- factor(all_acc$assembler, levels=assem)
fig4b <- ggplot(subset(all_acc, refcutoff==0.5 & tp > 10),
            aes(x=fpr, y=sensitivity, colour=species, linetype=assembler)) +
  geom_line() +
  theme_bw() +
  xlab('False positive rate') +
  ylab('True positive rate') +
  theme(legend.key = element_blank())

# Lay out the two panels
library(gridExtra)
fig4 <- arrangeGrob(fig4a, fig4b, ncol=2, widths=c(3, 2))
ggsave(plot=fig4, filename='figure_4/figure.pdf', width=15, height=4.5)
ggsave(plot=fig4, filename='figure_4/figure.png', width=15, height=4.5)

## Testing on arabidopsis simulation
data_dir <- ''
sim <- NULL
sim_binned <- NULL
sim_acc <- NULL
for(k in c(23, 33, 43, 53)) {
  dat <- load_data(
    paste('/data/fluxsim/ath/soap/k', k, '_into_Arabidopsis_thaliana.TAIR10.25.cdna.all.1.blast', sep=''),
    paste('/data/fluxsim/ath/soap/transrate_k', k, '.fa_contigs.csv', sep=''),
    'arabidopsis', paste('soap_k', k, sep=''), keepall=T)
  dat_binned <- bin_data(dat, 'arabidopsis',  paste('soap_k', k, sep=''))
  dat_acc <- acc_sweep(dat, 'arabidopsis',  paste('soap_k', k, sep=''))
  if (is.null(sim)) {
    sim <- dat
    sim_binned <- dat_binned
    sim_acc <- dat_acc
  } else {
    sim <- rbind(sim, dat)
    sim_binned <- rbind(sim_binned, dat_binned)
    sim_acc <- rbind(sim_acc, dat_acc)
  }
}

plot_binned(sim_binned)
ggplot(subset(sim_acc, tn > 0),
       aes(x=fpr, y=sensitivity, linetype=assembler, colour=factor(refcutoff))) +
  geom_line() +
  xlim(0, 1) +
  ylim(0, 1) +
  theme_bw()
