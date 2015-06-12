# Transrate paper - figure 5
# this code should not be called directly - is is loaded by the
# generate.R script in the parent directory

library(gridExtra)
library(ggplot2)

# unload dplyr and load it again to de-pollute the namespace
detach("package:dplyr", unload=TRUE)
library(dplyr)
theme_set(theme_bw(base_size = 9))

# first panel: distribution of contig scores
library(scales)
fig5a <- ggplot(wide_data[score > 0.01,],
                aes(x=score, fill=assembler)) +
  facet_grid(species~assembler, scales="free_y") +
  geom_histogram(binwidth=0.01) +
  scale_x_continuous(breaks=c(0.0, 0.5, 1.0), limits=c(-0.02, 1.02)) +
  scale_y_continuous(breaks=trans_breaks("identity", function(x) x, n=2)) +
  scale_fill_brewer(type="qual", palette=2) +
  scale_colour_brewer(type="qual", palette=2) +
  theme_bw() +
  xlab("contig score") +
  ylab("number of contigs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

fig5legend <- g_legend(fig5a)
fig5a <- fig5a + guides(fill=FALSE, alpha=FALSE)

# second panel: barchart of geometric mean of contig scores
geomean <- function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
library(dplyr)

fig5b_data <- group_by(wide_data, species, assembler) %>%
  summarise(gm_contig_score=geomean(score))
fig5b <- ggplot(fig5b_data, aes(x=assembler,
                       y=gm_contig_score,
                       fill=assembler)) +
  geom_bar(stat="identity") +
  scale_fill_brewer(type="qual", palette=2) +
  ylim(0, 1) +
  facet_grid(.~species, scales="free", space="free") +
  ylab("geometric mean of contig scores") +
  guides(fill=FALSE) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank())

# third panel: bar plot - proportion of input reads that mapped coherently
fig5c <- ggplot(assembly_data, aes(x=assembler,
                                   y=p_good_mapping,
                                   fill=assembler)) +
  geom_bar(stat="identity") +
  scale_fill_brewer(type="qual", palette=2) +
  ylim(0, 1) +
  facet_grid(.~species, scales="free", space = "free") +
  ylab("proportion of reads mapping") +
  guides(fill=FALSE) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank())

# fourth panel: bar plot - assembly score
fig5d <- ggplot(assembly_data, aes(x=assembler,
                                   y=score,
                                   fill=assembler)) +
  geom_bar(stat="identity") +
  scale_fill_brewer(type="qual", palette=2) +
  ylim(0, 1) +
  facet_grid(.~species, scales="free", space = "free") +
  ylab("assembly score") +
  guides(fill=FALSE) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank())

# fifth panel: optimised assembly score
fig5e <- ggplot(assembly_data, aes(x=assembler,
                                   y=optimal_score,
                                   fill=assembler)) +
  geom_bar(stat="identity") +
  scale_fill_brewer(type="qual", palette=2) +
  ylim(0, 1) +
  facet_grid(.~species, scales="free", space = "free") +
  ylab("optimal assembly score") +
  guides(fill=FALSE) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank())

fig5 <- arrangeGrob(fig5a, fig5b, fig5c, fig5d, fig5e, fig5legend,
                    ncol=2)

ggsave(fig5, filename = "figure_5/figure_with_merged.pdf", width = 10, height = 15)
ggsave(fig5, filename = "figure_5/figure_with_merged.png", width = 10, height = 15)

# save table of data for parts b, c, and d
fig5_export_data <- data.table(
  species = assembly_data$species,
  assembler = assembly_data$assembler,
  contig_score_geomean = fig5b_data$gm_contig_score,
  proportion_mapping = assembly_data$p_good_mapping,
  assembly_score = assembly_data$score
)
setkey(fig5_export_data, species, assembler)

write.table(fig5_export_data, "figure_5/figure5_panels_b-d_data.tsv", sep="\t", row.names=F)


# REAL DATA
real_meta <- subset(meta, datatype=="real")
real_data <- data.table()
real_cor <- data.table()

for (i in 1:nrow(real_meta)) {
  row <- real_meta[i, ]
  dt <- load_data_rbb(row[['blast']], row[['transrate']], row[['rsem']],
                  row[['species']], row[['assembler']], keepall=FALSE)
  real_data <- rbind(real_data, dt)
  dt_cor <- do_cor(dt, row[['species']], row[['assembler']])
  real_cor <- rbind(real_cor, dt_cor)
}

real_data[, sp:=factor(sp, levels=spp)]
real_data[, assembler:=factor(assembler, levels=assem)]

# venn diagrams of number of uniquely assembled reference transcripts per assembler
library(VennDiagram)
library(gridExtra)
library(RColorBrewer)
real_data[assembler=='merged', target:=sapply(filter(real_data, assembler=='merged')$target, function(x) {
  strsplit(x, "|", fixed=TRUE)[[1]][1]
})]
real_data[, target:=gsub(target, pattern="ENSMUSP", replacement="ENSMUST")]
real_data[, target:=gsub(target, pattern="ENSP", replacement="ENST")]


venncolours <- brewer.pal(3, "Set2")
plot_venn <- function(species, dt) {
  fn <- paste("figure_5/", dt$sp[1], "_venn_diagram.tiff", sep="")
  assem_names <- unique(dt$assembler)
  refsets <- lapply(assem_names, function(this_assem) {
    cutoff <- filter(assembly_data, assembler==this_assem,
                     species==species)$cutoff[1]
    un <- unique(filter(dt, assembler==this_assem, score >= cutoff,
                        accuracy > 0)$target)
    print(paste(species, this_assem, length(un), 'unique ref txps'))
    un
  })
  names(refsets) <- assem_names
  n <- length(assem_names)
  venn.diagram(x = refsets, filename=NULL, main=dt$sp[1],
               width=2, height=2, units="in",
               fontface="bold", fontfamily="sans", cex=0.8,
               cat.fontfamily="sans", cat.col = venncolours[1:n],
               main.fontface="bold", main.fontfamily="sans",
               main.pos= c(0.5, 0.15), rotation.degree=60,
               fill=venncolours[1:n], na="remove",
               cat.default.pos="outer", margin=0.1, cat.dist=0.05,
               euler.d=FALSE, scaled=FALSE, reverse=TRUE)
}
venn_plots <- lapply(unique(real_data$sp), function(species) {
  print(species)
  gTree(children=plot_venn(species,
                           filter(real_data, sp==species)))
})
pdf("figure_5/venn_panel_with_merged.pdf")
do.call(grid.arrange, venn_plots)
dev.off()

# barplot showing proportion of transcripts best represented by each assembler
getprops_a <- function(x) {
  n <- nrow(x)
  group_by(x, assembler) %>%
    do(getprops_b(., n))
}
getprops_b <- function(x, n) {
  data.table(assembler=x$assembler[1],
             pc=nrow(x)/n)
}
fig5e_data <- (filter(real_data, assembler != 'merged') %>%
  group_by(sp, target) %>%
  top_n(n = 1, wt = score) %>%
  group_by(sp) %>%
  do(getprops_a(.)))
fig5_e <- fig5e_data %>%
  ggplot(aes(x=assembler, y=pc*100, fill=assembler)) +
  geom_bar(stat="identity") +
  facet_grid(. ~ sp, space="free_x", scales="free_x") +
  theme_bw() +
  ylab("Percentage of reference transcripts\nbest represented in assembly") +
  scale_fill_brewer(type="qual", palette=2) +
  theme(axis.title.y = element_text(face="bold"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank()) +
  guides(fill = FALSE)
ggsave("figure_5/fig5e_count_of_best_assembled_txps_per_assembler_real_data.png",
       fig5_e, height=6, width=7)
ggsave("figure_5/fig5e_count_of_best_assembled_txps_per_assembler_real_data.pdf",
       fig5_e, height=6, width=7)
