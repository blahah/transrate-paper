# Transrate paper - figure 6

fig6_data <- read.csv('../data/tsa-results.txt', sep="\t", as.is=T)
names(fig6_data) <- c('code', 'score', 'read_length', 'full_tools', 'phylogeny',
                      'method')
fig6_data[fig6_data$method=='sdt','method'] <- 'soap'
fig6_data$read_length[fig6_data$read_length == 'unknown'] <- NA
fig6_data$read_length <- as.numeric(fig6_data$read_length)
fig6_data$clade <- sapply(fig6_data$phylogeny, function(line) {
  phylo <- strsplit(line, split=";", fixed=T)
  clade <- phylo[[1]][5]
  return(gsub("^\\s+|\\s+$", "", clade))
})

fig6a <- ggplot(fig6_data, aes(x=score)) +
  geom_histogram(binwidth=0.05) +
  xlim(0.0, 0.6) +
  theme_bw() +
  xlab('assembly score')

fig6b_tab <- data.frame(table(fig6_data$clade))
fig6b_data <- subset(fig6_data, clade %in% subset(fig6b_tab, Freq >= 10)$Var1)
fig6b <- ggplot(fig6b_data, aes(x=score)) +
  geom_histogram() +
  facet_grid(clade~.) +
  theme_bw() +
  scale_y_continuous(breaks=c(0, 5)) +
  xlim(0.0, 0.6) +
  guides(fill=FALSE) +
  xlab('assembly score') +
  theme(strip.text.y = element_text(angle = 0))

fig6c_tab <- data.frame(table(fig6_data$method))
fig6c_data <- subset(fig6_data, method %in% subset(fig6c_tab, Freq >= 10)$Var1)
fig6c <- ggplot(fig6c_data, aes(x=score)) +
  geom_histogram() +
  facet_grid(method~.) +
  scale_y_continuous(breaks=c(0, 4)) +
  xlim(0.0, 0.6) +
  theme_bw() +
  guides(fill=FALSE) +
  xlab('assembly score') +
  theme(strip.text.y = element_text(angle = 0))

fig6d <- ggplot(fig6_data, aes(x=read_length, y=score)) +
  geom_point() +
  stat_smooth(method="lm") +
  theme_bw() +
  scale_x_continuous(breaks=c(50, 100, 150)) +
  ylim(0.0, 0.6) +
  xlab('read length') +
  ylab('assembly score')

fig6 <- arrangeGrob(fig6a, fig6b, fig6c, fig6d, ncol=4, widths=c(1, 1, 1, 1))
ggsave(fig6, filename = "figure_6/figure.pdf", width = 12, height = 3)
ggsave(fig6, filename = "figure_6/figure.png", width = 12, height = 3)
