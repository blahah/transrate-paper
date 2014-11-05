## Skype

## Figures

### fig 1

- could be graphical abstract

### fig 2

- in correlation plot:
  - blank out diagonal
  - make scale bar go from -1 to 1
- in order to avoid trinity dominating correlation,
  - sample 5,000 random transcripts from each assembly from each species
  - use that data to compute the correlation coefficient
  - could do that 100 times and take the average

- in distribution plot:
 - reorder the species: mouse, rice, human, yeast
 - have to consider removing the ambiguous bases component of the score because

Trinity lies about it
 - for assemblies that do have ambiguous bases, edit distance should correlate with inverse edit distance
 - should demonstrate this with a plot

## fig 4

- should be an association between quality of the read data and whether they performed well in assembly (across all assemblers)
- overlay some read quality data that demonstrates this
  - error rate in reads (e.g. FastQC reports)
  - BayesHammer to estimate error rate

- add bar plots underneath the distributions showing the score of the read data in FastQC and BayesHammer

## fig5

- fewer partitions on the y axis (just 0, 5, 10)
- on x axis show exponent rather than number

maybe figure 5 and 6 should be switched for the narrative - we want to show our score is correct first, then show why
