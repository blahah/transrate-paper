# Transrate paper - figure 5

# This figure includes two scatter plots. Because we have over 3 million data
# points, we subsample down to 500,000 points before plotting
ungroup(wide_data)
fig5_data <- sample_n(wide_data, 500000)

# The first panel shows contig score plotted against contig length,
# faceted by assembler and species, and with a gradient overlaid to
# show point density

fig5a <- ggplot(fig5_data,
                aes(x=score, y=length)) +
  geom_point() +
  stat_density2d(aes(alpha=..level.., fill=..level..),
                 bins=20, geom="polygon") +
  scale_fill_gradient(low = "yellow", high = "red") +
  scale_alpha(range = c(0.1, 0.7), guide = FALSE) +
  scale_y_log10() +
  scale_x_continuous(breaks=c(0.0, 0.5, 1.0),
                     limits=c(-0.02, 1.02)) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_grid(assembler~species) +
  ylab("contig length") +
  xlab("contig score") +
  guides(alpha=FALSE, fill=FALSE)

# The second panel shows contig score plotted against effective coverage,
# faceted by assembler and species, and with a gradient overlaid to
# show point density
fig5b <- ggplot(fig5_data,
                aes(x=score, y=coverage)) +
  geom_point() +
  stat_density2d(aes(alpha=..level.., fill=..level..),
                 bins=20, geom="polygon") +
  scale_fill_gradient(low = "yellow", high = "red", guide = guide_legend(title="Density")) +
  scale_alpha(range = c(0.1, 0.7), guide = FALSE) +
  scale_y_log10() +
  scale_x_continuous(breaks=c(0.0, 0.5, 1.0),
                     limits=c(-0.02, 1.02)) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_grid(assembler~species, scales="free") +
  ylab("contig effective coverage") +
  xlab("contig score")

# We want to have one legend shared between the two plots,
# and each plot the same size
legend <- g_legend(fig5b)
fig5b <- fig5b + guides(fill=FALSE, alpha=FALSE)

# Layout the two panels one above the other
fig5 <- arrangeGrob(fig5a, fig5b, legend, ncol=3, widths=c(5, 5, 1))
ggsave(fig5, filename = "figure_5/figure.pdf", width = 12, height = 4)
ggsave(fig5, filename = "figure_5/figure.png", width = 12, height = 4)
