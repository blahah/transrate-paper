# Transrate paper - figure 6

# parse out just the assembler name from the tool list
tool_cleanup <- function(x) {
  for (tool in c('trinity', 'oases', 'soap', 'clc',
                 'newbler', 'velvet', 'abyss', 'cufflinks')) {
    rows <- grep(tool, tolower(x), fixed=TRUE)
    x[rows] <- tool
  }
  print(unique(x))
  x[x == 'velvet'] <- 'oases'
  x
}

# parse out the clade from the NCBI phylogeny list
clade_cleanup <- function(x) {
  x <- gsub(x, pattern=";[^\\s]", replacement="; ")
  x <- sapply(x, function(y) {
    strsplit(y, "; ")[[1]][5]
  })
  x[is.na(x)] <- 'unknown'
  x
}

fig6_raw <- read.csv('../data/tsa-results.txt', sep="\t", as.is=T)
fig6_data <- data.table(
  fig6_raw[, 1:7], # code, score, optimal, cutoff, read_length, read_pairs, n_bases
  tool = tool_cleanup(fig6_raw$tool),
  phylogeny = clade_cleanup(fig6_raw$phylogeny),
  gc_content = (fig6_raw$read_gc_content_1 + fig6_raw$read_gc_content_2) / 2,
  mean_qual = (fig6_raw$mean_sequence_quality_1 + fig6_raw$mean_sequence_quality_2) / 2,
  deduped = (fig6_raw$total_deduplicated_1 + fig6_raw$total_deduplicated_2) / 2
)

fig6_data[, coverage := exp(log(read_pairs) + log(read_length) - log(n_bases))]
fig6_data[read_length == 'unknown', read_length := NA]
fig6_data[, read_length := as.numeric(read_length)]
write.csv(fig6_data, "supplemental_file_2.csv")

fig6a_data <- melt(select(fig6_data, code, score, optimal), id=c('code'))
# panel a - cumulative distribution of scores
fig6a <- ggplot(fig6a_data, aes(x=value, colour=variable)) +
  stat_ecdf() +
  xlim(0, 0.65) +
  xlab("TransRate assembly score") +
  ylab("Cumulative proportion of published assemblies\nwith a score at least this good") +
  scale_colour_discrete(name="Score type") +
  theme_bw() +
  theme(legend.justification=c(1,0), legend.position=c(1,0))

# panel b - score vs optimal score
fig6b <- ggplot(fig6_data, aes(x=score, y=optimal)) +
  geom_point() +
  theme_bw() +
  xlim(0, 0.6) +
  ylim(0, 0.6) +
  ylab('TransRate optiimal assembly score') +
  xlab('TransRate raw assembly score') +
  geom_abline(intercept=0, slope=1, colour="red")

fig6c_tab <- data.frame(table(fig6_data$phylogeny))
fig6c_data <- subset(fig6_data, phylogeny %in% subset(fig6c_tab, Freq >= 10)$Var1)
fig6c <- ggplot(fig6c_data, aes(x=optimal)) +
  geom_histogram() +
  facet_grid(phylogeny~.) +
  theme_bw() +
  scale_y_continuous(breaks=c(0, 5)) +
  xlim(0.0, 0.6) +
  guides(fill=FALSE) +
  xlab('assembly score') +
  theme(strip.text.y = element_text(angle = 0)) +
  xlab("TransRate optimal assembly score") +
  ylab("Number of assemblies")

fig6d_tab <- data.frame(table(fig6_data$tool))
fig6d_data <- subset(fig6_data, tool %in% subset(fig6d_tab, Freq >= 5)$Var1)
fig6d <- ggplot(fig6d_data, aes(x=optimal)) +
  geom_histogram() +
  facet_grid(tool~.) +
  scale_y_continuous(breaks=c(0, 4)) +
  xlim(0.0, 0.6) +
  theme_bw() +
  guides(fill=FALSE) +
  xlab("TransRate optimal assembly score") +
  ylab("Number of assemblies") +
  theme(strip.text.y = element_text(angle = 0))

fig6e <- ggplot(fig6_data, aes(y=read_length, x=optimal)) +
  geom_point() +
  theme_bw() +
  scale_y_continuous(breaks=c(50, 100, 150)) +
  xlab("TransRate optimal assembly score") +
  ylab("Read length")

# function to decorate a plot with linear model summary (incl R^2)
lm_eqn <- function(df){
  m <- lm(y ~ x, df);
  eq <- substitute(italic(r)^2~"="~r2,
                   list(r2 = format(summary(m)$r.squared, digits = 3)))
  as.character(as.expression(eq));
}

fig6_data[, x:=optimal]
fig6_data[, y:=gc_content]

# panel f - %GC in reads vs score
fig6f <- ggplot(fig6_data, aes(y=gc_content, x=optimal)) +
  geom_point() +
  theme_bw() +
  xlab('TransRate optimal assembly score') +
  ylab('Read GC%') +
  ylim(20, 80) +
  geom_smooth(method = "lm", se=FALSE, color="blue", formula = y ~ x) +
  annotate(x = 0.12, y = 28, geom = "text", label = lm_eqn(fig6_data), parse = TRUE)



fig6_data[, y:=mean_qual]

# panel g - read quality vs optimal score
fig6g <- ggplot(fig6_data, aes(y=mean_qual, x=optimal)) +
  geom_point() +
  theme_bw() +
  xlab('TransRate optimal assembly score') +
  ylab('Mean read Phred score') +
  geom_smooth(method = "lm", se=FALSE, color="blue", formula = y ~ x) +
  annotate(x = 0.12, y = 28, geom = "text", label = lm_eqn(fig6_data), parse = TRUE)

# panel f - deduplication vs optimal score
fig6_data[, y:=deduped]
fig6h <- ggplot(fig6_data, aes(y=deduped, x=optimal)) +
  geom_point() +
  theme_bw() +
  xlab('TransRate optimal assembly score') +
  ylab('% of reads duplicated') +
  ylim(0, 100) +
  geom_smooth(method = "lm", se=FALSE, color="blue", formula = y ~ x) +
  annotate(x = 0.5, y = 0.55, geom = "text", label = lm_eqn(fig6_data), parse = TRUE)

# panel i - number of reads vs optimal score
fig6_data[, y:=read_pairs]
fig6i <- ggplot(fig6_data, aes(y=read_pairs, x=optimal)) +
  geom_point() +
  theme_bw() +
  xlab('TransRate optimal assembly score') +
  ylab('Number of read pairs') +
  scale_y_log10() +
  geom_smooth(method = "lm", se=FALSE, color="blue", formula = y ~ x) +
  annotate(y = 1.5e08, x = 0.35, geom = "text", label = lm_eqn(fig6_data), parse = TRUE)

# panel j - read coverage vs optimal score
fig6_data[, y:=log(coverage)]
fig6j <- ggplot(fig6_data, aes(x=optimal, y=coverage)) +
  geom_point() +
  theme_bw() +
  xlab('TransRate optimal assembly score') +
  ylab('Read bases per assembly base (log)') +
  scale_y_log10() +
  geom_smooth(method = "lm", se=FALSE, color="blue", formula = y ~ x) +
  annotate(x = 0.55, y = 300, geom = "text", label = lm_eqn(fig6_data), parse = TRUE)


fig6 <- arrangeGrob(fig6a, fig6b, fig6c, fig6d,
                    fig6e, fig6f, fig6g, fig6h,
                    fig6i, fig6j, ncol=2, widths=c(1, 1, 1, 1))
ggsave(fig6, filename = "figure_6/figure_alternative.pdf", width = 9, height = 22.5)
ggsave(fig6, filename = "figure_6/figure_alternative.png", width = 9, height = 22.5)


# Multiple linear regression.
# here we calculate the proportion of variance explained by
# the thre explanatory variables that appear to correlate with
# assembly score and optimal assembly score
p_opt_explained <- summary(lm(optimal ~  mean_qual + deduped + coverage, data=fig6_data))$r.squared
p_raw_explained <- summary(lm(score ~  mean_qual + deduped + coverage, data=fig6_data))$r.squared
print("TSA dataset multiple linear regression analysis")
print("The proportion of variance in the optimal score explained")
print(paste("by Phred score, duplication, and coverage was: ", round(p_opt_explained, 2)))
print("The proportion of variance in the raw score explained")
print(paste("by Phred score, duplication, and coverage was: ", round(p_raw_explained, 2)))
