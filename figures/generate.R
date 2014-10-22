## Transrate paper, Figure 3

setwd('~/code/transrate-paper/figures/')

# The first panel of this figure shows
# the distribution of each contig-score component
# for each of the test assemblies.
# Distributions are line-histograms, one plot per combination
# of species and score component. Columns are species, rows
# are metrics. Plots contain one line per assembly.

## 1. Load data

species_list <- c('mouse', 'rice', 'human', 'yeast')
assemblers <- c('trinity', 'oases', 'soapdenovotrans')
datasets <- expand.grid(species_list, assemblers)
datasets <- apply(datasets, MARGIN = 2, FUN = as.character)

score_cols <- c('p_good', 'p_bases_covered',
                'inverse_edit_dist', 'p_unique_bases', 'score',
                'length', 'effective_mean_coverage')
data <-  data.frame()
wide_data <- data.frame()
library(reshape2)

for (rowno in 1:nrow(datasets)) {
  # generate path to the contig files
  species <- datasets[rowno, 1]
  assembler <- datasets[rowno, 2]
  dirs <- c('..', 'data', species, 'transrate', assembler)
  path <- paste(dirs, collapse="/")
  if (!file.exists(path)) {
    next
  }

  # list all contig files and select the most recent one
  files <- data.frame(file = paste(path,
                                   list.files(path, pattern = "*contigs*"),
                                   sep="/"),
                      stringsAsFactors = FALSE)
  files$mtime <- unlist(lapply(files$file, function(x){ file.info(x)$mtime}))
  mostrecent <- subset(files, mtime == max(files$mtime))$file

  # load the most recent file and save the relevant columns
  csv <- read.csv(mostrecent, as.is=T)[,score_cols]
  # normalise inverse edit distance
  # TODO: remove this once it's implemented in transrate
  csv$inverse_edit_dist <- (csv$inverse_edit_dist - 0.65) * (1 / 0.35)
  csv$species <- species
  csv$assembler <- assembler
  wide_data <- rbind(wide_data, csv[complete.cases(csv),])
  csv <- melt(csv, id.vars = c('species', 'assembler', 'score', 'length', 'effective_mean_coverage'),
              variable.name = 'score_component')
  data <- rbind(data, csv[complete.cases(csv),])
}
data$assembler[data$assembler == 'soapdenovotrans'] <- 'soapdt'

# fixing the score
# TODO: remove this once implemented
comp <- c('p_good', 'p_bases_covered',
          'inverse_edit_dist', 'p_unique_bases')
wide_data$score <- apply(wide_data[,comp], 1, function(x){
  return(prod(x))
})
data <- melt(wide_data, id.vars = c('species', 'assembler', 'score',
                                    'length', 'effective_mean_coverage'),
             variable.name = 'score_component')
data$species <- factor(data$species, levels=species_list)

## 2. Plot

library(ggplot2)
left_panel <- ggplot(data[c('score_component', 'species', 'assembler', 'value')],
            aes(x=value, colour=assembler)) +
  geom_step(stat = "bin", binwidth=0.02) +
  scale_y_log10() +
  scale_x_continuous(breaks=c(0.0, 0.5, 1.0), limits=c(-0.02, 1.02)) +
  facet_grid(species~score_component, scales="free_y") +
  theme_bw() +
  xlab("Score") +
  ylab("Count")

ggsave(left_panel, filename = "figure_3/figure_3a.pdf", width = 10, height = 5)


# The second panel of this figure shows
# each contig score component plotted against each other one
# first downsample the data
library(plyr)
downsampled <- ddply(wide_data, .(assembler, species), function(x) {
  x[sample(1:nrow(x), 5000),]
})
cor_data <- melt(cor(downsampled[,1:4]))
right_panel <- ggplot(cor_data,
       aes(x=Var1, y=Var2, fill=value)) +
  geom_tile() +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_fill_gradient2(na.value = "grey10", limits = c(-1, 1)) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  labs(x=NULL, y=NULL)
ggsave(right_panel, filename = "figure_3/figure_3b.pdf", width = 3, height = 3)


## Layout the two figures side-by-side
library(gridExtra)
fig <- arrangeGrob(left_panel, right_panel, ncol=2, widths=c(3, 2))
ggsave(fig, filename = "figure_3/figure.pdf", width = 10, height = 3)


## Figure 4.

# This figure shows the distribution of contig scores for each species and assembler,
# as well as the number of contigs in each assembly with a score > 0.5

# first panel: distribution of contig scores
fig4top <- ggplot(data[,c('species', 'assembler', 'score')],
               aes(x=score, colour=assembler)) +
  geom_step(stat = "density", na.rm=T, kernel = "rectangular", adjust=1/2) +
  scale_x_continuous(breaks=c(0.0, 0.5, 1.0), limits=c(-0.02, 1.02)) +
  facet_grid(species~., scales="free_y") +
  theme_bw() +
  xlab("Contig score") +
  ylab("Density")

# second panel: number of contigs in each assembly with a score > 0.5
fig4bottom <-
  ggplot(subset(data[,c('species', 'assembler', 'score')], score > 0.5),
         aes(x=assembler, fill=assembler, colour=assembler)) +
  facet_grid(species~., scales="free_y") +
  geom_bar() +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.x = element_blank())

fig4 <- arrangeGrob(fig4top, fig4bottom, ncol=2)
ggsave(plot, filename = "figure_4/figure.pdf", width = 10, height = 3)


## Figure 5

# This figure is composed of two panels, showing the distribution of contig
# score with (a) contig length and (b) expression level

# The first panel shows contig score plotted against contig length,
# coloured by assembler and with point style mapped to species
fig5_a <- ggplot(data[sample(nrow(data), 100000), c('species', 'assembler', 'score', 'length')],
                 aes(x=length, y=score, pch=species)) +
  stat_density2d(aes(alpha=..level.., fill=..level..),
                 bins=5, geom="polygon") +
  scale_fill_gradient(low = "yellow", high = "red") +
  scale_alpha(range = c(0.1, 0.7), guide = FALSE) +
  geom_density2d(colour="black", bins=5) +
  scale_x_log10() +
  scale_y_continuous(breaks=seq(from=0.0, to=1.0, by=0.2),
                     limits=c(-0.02, 1.02)) +
  theme_bw() +
  facet_grid(assembler~species) +
  xlab("contig length (log10)") +
  ylab("contig score") +
  guides(alpha=FALSE, fill=FALSE)

# The second panel shows contig score plotted against effective coverage,
# coloured by assembler and with point style mapped to species
fig5_b <- ggplot(data[sample(nrow(data), 100000),c('species', 'assembler', 'score', 'effective_mean_coverage')],
                 aes(x=effective_mean_coverage, y=score, pch=species)) +
  stat_density2d(aes(alpha=..level.., fill=..level..),
                 bins=5, geom="polygon") +
  scale_fill_gradient(low = "yellow", high = "red", guide = guide_legend(title="Density")) +
  scale_alpha(range = c(0.1, 0.7), guide = FALSE) +
  geom_density2d(colour="black", bins=5) +
  scale_x_log10() +
  scale_y_continuous(breaks=seq(from=0.0, to=1.0, by=0.2),
                     limits=c(-0.02, 1.02)) +
  theme_bw() +
  facet_grid(assembler~species, scales="free") +
  xlab("contig effective coverage (log10)") +
  ylab("contig score")

# We want to have one legend shared between the two plots,
# and each plot the same size
g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}
legend <- g_legend(fig5_b)
fig5_b <- fig5_b + guides(fill=FALSE, alpha=FALSE)

# Layout the two panels one above the other
fig5 <- arrangeGrob(fig5_a, fig5_b, legend, ncol=3, widths=c(5, 5, 1))
ggsave(fig5, filename = "figure_5/figure.pdf", width = 10, height = 5)
