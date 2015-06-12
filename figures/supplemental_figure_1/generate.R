
# figure 4 panel c - plot showing score optimisation
fig4c_data <- fread(paste(data_dir, 'rice/full_assembly/assembly_score_optimisation.csv', sep="/"))
fig4c_data2 <- fread(paste(data_dir, 'rice/full_assembly/transrate_assemblies.csv', sep="/"))
fig4c_data <- filter(fig4c_data, !is.nan(assembly_score))
fig4c_data[, assembly_score := as.numeric(assembly_score)]
fig4c_data <- rbind(list(0, fig4c_data2$score[1]),fig4c_data)
fig4c <- ggplot(fig4c_data, aes(x=cutoff, y=assembly_score)) +
  geom_line() +
  theme_bw() +
  xlab("Contig score cutoff") +
  ylab("TransRate assembly score of remaining contigs") +
  xlim(0, 1) +
  geom_vline(xintercept=fig4c_data$cutoff[which.max(fig4c_data$assembly_score)], colour = "green", label="cutoff")
ggsave(filename = "figure_4/panel_c_score_optimisation.png",
       plot = fig4c, width=7, height=7)
