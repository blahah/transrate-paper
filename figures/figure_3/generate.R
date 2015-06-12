# Transrate paper - figure 3

# The first panel of this figure shows
# the distribution of each contig-score component
# for each of the test assemblies.
# Distributions are line-histograms, one plot per combination
# of species and score component. Columns are species, rows
# are metrics. Plots contain one line per assembly.
library(ggplot2)
fig3a <- ggplot(data, aes(x=value, colour=assembler)) +
  geom_step(stat = "bin", binwidth=0.02) +
  scale_y_log10() +
  scale_x_continuous(breaks=c(0.0, 0.5, 1.0), limits=c(-0.02, 1.02)) +
  scale_colour_brewer(type="qual", palette=2) +
  facet_grid(species~score_component, scales="free_y") +
  theme_bw() +
  xlab("score component value") +
  ylab("number of contigs")

# The second panel of this figure shows how each score component
# correlates with each other component across all the assemblies.
# Because each assembly has a different number of contigs, the number of
# contigs in the smallest assembly is sampled from each assembly for the
# correlation, to avoid any assembly dominating.

# first downsample the data
library(plyr)
downsampled <- sample_n(wide_data, 5000)
cor_data <- melt(cor(downsampled[,1:4, with=F]))
fig3b <- ggplot(cor_data,
                aes(x=Var1, y=Var2, fill=value)) +
  geom_tile() +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_fill_gradientn(colours = rainbow(3), limits=c(-1, 1)) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  labs(x=NULL, y=NULL) +
  geom_text(aes(label=round(value, 2)))

## Layout the two figures side-by-side
library(gridExtra)
fig3 <- arrangeGrob(fig3a, fig3b, ncol=2, widths=c(3, 2))
ggsave(fig3, filename = "figure_3/figure.pdf", width = 15, height = 4.5)
ggsave(fig3, filename = "figure_3/figure.png", width = 15, height = 4.5)
