# Transrate paper - figure 3

# first panel: distribution of contig scores
library(scales)
fig3a <- ggplot(wide_data[score > 0.01,],
                aes(x=score, fill=assembler)) +
  facet_grid(species~assembler, scales="free_y") +
  geom_histogram(binwidth=0.01) +
  scale_x_continuous(breaks=c(0.0, 0.5, 1.0), limits=c(-0.02, 1.02)) +
  scale_y_continuous(breaks=trans_breaks("identity", function(x) x, n=3)) +
  scale_fill_brewer(type="qual", palette=2) +
  scale_colour_brewer(type="qual", palette=2) +
  theme_bw() +
  xlab("contig score") +
  ylab("number of contigs") +
  guides(fill=FALSE, alpha=FALSE)

# second panel: bar plot - number of contigs in each assembly with a score > 0.5
fig3b <-
  ggplot(wide_data[score > 0.5,],
         aes(x=assembler, fill=assembler)) +
  facet_grid(.~species, scales="free_x", space="free_x") +
  ylab("num. contigs scoring > 0.5") +
  geom_bar() +
  scale_fill_brewer(type="qual", palette=2) +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.x = element_blank())
fig3legend <- g_legend(fig3b)
fig3b <- fig3b + guides(fill=FALSE, alpha=FALSE)
fig3 <- arrangeGrob(fig3a, fig3b, fig3legend, ncol=3, widths=c(5, 5, 1))

ggsave(fig3, filename = "figure_3/figure.pdf", width = 15, height = 4.5)
ggsave(fig3, filename = "figure_3/figure.png", width = 15, height = 4.5)

