## Transrate paper, Figure 3

setwd('~/code/transrate-paper/figures/figure_3')

# The first panel of this figure shows
# the distribution of each contig-score component
# for each of the test assemblies.
# Distributions are line-histograms, one plot per combination
# of species and score component. Columns are species, rows
# are metrics. Plots contain one line per assembly.

## 1. Load data

species <- c('human', 'mouse', 'rice', 'yeast')
assemblers <- c('trinity', 'oases', 'soapdenovotrans')
datasets <- expand.grid(species, assemblers)
datasets <- apply(datasets, MARGIN = 2, FUN = as.character)

score_cols <- c('p_good', 'p_bases_covered', 'prop_unambiguous',
                'inverse_edit_dist', 'p_unique_bases', 'score')
data <-  data.frame()
wide_data <- data.frame()
library(reshape2)

for (rowno in 1:nrow(datasets)) {
  # generate path to the contig files
  species <- datasets[rowno, 1]
  assembler <- datasets[rowno, 2]
  dirs <- c('..', '..', 'data', species, 'transrate', assembler)
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
  csv$inverse_edit_dist <- (csv$inverse_edit_dist - 0.72) * (1 / 0.28)
  csv$species <- species
  csv$assembler <- assembler
  wide_data <- rbind(wide_data, csv[complete.cases(csv),])
  csv <- melt(csv, id.vars = c('species', 'assembler', 'score'),
              variable.name = 'score_component')
  data <- rbind(data, csv[complete.cases(csv),])
}
data$assembler[data$assembler == 'soapdenovotrans'] <- 'soapdt'

## 2. Plot

library(ggplot2)
left_panel <- ggplot(data[c('score_component', 'species', 'assembler', 'value')],
            aes(x=value, colour=assembler)) +
  geom_step(stat = "bin") +
  scale_y_log10() +
  scale_x_continuous(breaks=c(0.0, 0.5, 1.0), limits=c(-0.02, 1.02)) +
  facet_grid(species~score_component, scales="free_y") +
  theme_bw() +
  xlab("Score") +
  ylab("Count")

ggsave(left_panel, filename = "figure_3a.pdf", width = 10, height = 5)


# The second panel of this figure shows
# each contig score component plotted against each other one
cor_data <- melt(cor(wide_data[,1:5]))
right_panel <- ggplot(cor_data,
       aes(x=Var1, y=Var2, fill=value)) +
  geom_tile() +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_fill_gradient2() +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  labs(x=NULL, y=NULL)
ggsave(right_panel, filename = "figure_3b.pdf", width = 3, height = 3)


## Layout the two figures side-by-side
library(gridExtra)
fig <- arrangeGrob(left_panel, right_panel, ncol=2, widths=c(3, 2))
ggsave(fig, filename = "figure.pdf", width = 10, height = 3)
