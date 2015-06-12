# Transrate paper - figure 4

data_dir <- '../data'

library(ggplot2)
library(data.table)
library(dplyr)

# correlation analysis
# reshape the local correlation data
library(reshape2)
sim_cor[, left:=c('transrate',
                  'rsem_eval', 'reference')]
setnames(sim_cor, c('species', 'assembler', 'transrate',
                    'rsem_eval', 'reference', 'left'))
sim_cor <- melt(sim_cor, id.vars=c('species', 'assembler', 'left'))

# global correlation analysis
# find spearman correlation between all score components, transrate score,
# rsem score and refscore
dt_cor <- function(dt) {
  res <- cor(dt[, -c(1), with=F], method="spearman")
  rn <- rownames(res)
  dt <- data.table(res)
  dt[, column:=rn]
}

# take the mean across species of each correlation
dt_colwise_mean <- function(dt) {
  ungroup(dt) %>%
  select(-(sp)) %>%
  select(-(column)) %>%
  `[`(, lapply(.SD, mean))
}

global_mean_cor <- function(dt) {
  group_by(dt, sp) %>%
    select(score, contig_impact_score, accuracy) %>%
    do(dt_cor(.)) %>%
    group_by(column) %>%
    do(dt_colwise_mean(.))
}

# supplementary file 1 - correlation of transrate and RSEM-eval with
# reference-based accuracy
sim_rbb_global_mean_cor <- global_mean_cor(sim_data_rbb)
write.csv(x=sim_rbb_global_mean_cor, file="supplemental_file_1.csv")
transrate_rbb_score_cor <- round(sim_rbb_global_mean_cor$accuracy[1], 2)
rsem_rbb_score_cor <- round(sim_rbb_global_mean_cor$accuracy[2], 2)

# from here on, we need to prevent losing RSEM-eval data points by
# setting all negative numbers to the minimum positive number
min_pos_cis <- min(sim_data_rbb[contig_impact_score > 0, contig_impact_score])
sim_data_rbb[contig_impact_score < min_pos_cis, contig_impact_score:=0.01]
sim_data_rbb[, contig_impact_score_log:=log(contig_impact_score)]

# figure 5 panel y - transrate contig scores and rsem-eval contig scores plotted
# against accuracy
# sim_data[, contig_impact_score_exp:=exp(contig_impact_score)]
library(gridExtra)
fig4a <- filter(sim_data_rbb, !is.na(target)) %>%
  ggplot(aes(x=score, y=accuracy)) +
  geom_point(size=1, alpha=0.3) +
  xlab("TransRate contig score") +
  ylab("Accuracy of assembled contig") +
  theme_bw() +
  scale_color_brewer(name="Species", type="qual", palette=7) +
  theme(axis.title.x = element_text(face="bold"),
        axis.title.y = element_text(face="bold"),
        legend.key = element_blank()) +
  guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3))) +
  annotate(x = 0.7, y = 0.05, geom = "text",
           label=paste("spearman: ", transrate_rbb_score_cor),
           fontface="bold", size=10)
ggsave(filename = "figure_4/panel_a_scatter_contig_score_vs_accuracy.png",
       plot = fig4a, width = 7, height = 7)

fig4b <- filter(sim_data_rbb, !is.na(target)) %>%
  ggplot(aes(x=contig_impact_score_log, y=accuracy)) +
  geom_point(size=1, alpha=0.3) +
  xlab("RSEM contig impact score (log)") +
  ylab("Accuracy of assembled contig") +
  theme_bw() +
  scale_color_brewer(type="qual", palette=7) +
  theme(axis.title.x = element_text(face="bold"),
        axis.title.y = element_text(face="bold"),
        legend.key = element_blank()) +
  guides(colour = guide_legend(override.aes = list(alpha = 1, size = 3))) +
  annotate(x = 11, y = 0.05, geom = "text",
           label=paste("spearman: ", rsem_rbb_score_cor),
           fontface="bold", size=10)
ggsave(filename = "figure_4/panel_b_scatter_rsem_score_vs_accuracy.png",
       plot = fig4b, width = 7, height = 7)

# save contig data
write.table(sim_data_rbb, 'figure_4/simulated_contig_data_rbb_only.tsv', sep="\t",
            row.names=F)

# save binning data
write.table(sim_binned, 'figure_5/simulated_binning_data.tsv', sep="\t",
            row.names=F)

# save cor data
write.table(sim_cor, 'figure_5/simulated_correlation_data.tsv', sep="\t",
            row.names=F)

# save global cor data
write.table(sim_rbb_global_mean_cor, 'figure_4/simulated_global_mean_correlation_data_rbb_only.tsv', sep="\t", row.names=F)
