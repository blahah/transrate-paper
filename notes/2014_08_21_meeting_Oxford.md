## Transrate paper notes

### Rice dataset from soap

- ORFs mid-sequence need to start with M
- Why is Trinity GC skew so different?
- Whether the GC bias in the assembly represents the GC bias in the reads
  - least squares distance or euclidean distance between them
  - total variation distance of probability measures
- Proportion of kmers in reads captured in transcriptome assembly as a measure of completeness?

### Transrate score

- take geometric mean of all contig scores
  - can't have contig scores of 0
- take geometric mean of that score and the proportion of reads that mapped good  

### Contig score

consists of

1. direct probabilities
2. functions of metrics

#### Direct probabilities

- proportion of bases with any coverage > 0
- proportion of bases not ambiguous
- proportion of reads mapping to the contig that map good
- 1 - edit distance (normalised across the dataset?)
- proportion of bases with mapQ >5 (maybe change to geometric mean of mapq probs - try and plot)

test this by running the score analysis on an existing dataset
- look at top 10
- look at bottom 10
- plot 5x5 the score metrics
- plot 5x5 spearman correlation of score metrics
- plot distribution of scores

## Analyse a shitload of assemblies from the Transcriptome Shotgun Archive

only take assemblies if:

- we know what the assembler is
- if it has 2 SRA files (left and right)
- if it has > 5000 contigs

analyse them all with contig and read metrics, before and after filtering the crap


## Correctness things to sort out

- normalise inverse edit distance prob
- calculate p_bases_covered and p_unique_bases by considering only the effective contig
- include length cutoff in the score -> don't need to do this if we sort out good read alignments as below
- double check all score calculations
- p_good should *not* allow reads where the mate doesn't map the same contig

## Plots to try

- proportion of bases in each score decile
- variances of the log normalised coverage levels
- distribution of p-values for komolgorov-smirnov test for normality
- distribution for all sequences of the probability

## Segmentation

- KS test
- bayesian segmentation but do discretised log2 of coverage so we have only a few discrete values, adapt Steve's script

## Evidence for validation

### 1 - genome

#### part A

- align to genome using exonerate
- don't make assumption that all transcripts represent protein, all contigs should align full-length to genome allowing for introns
- bin contigs by transrate score decile (something like precision)
- plot percentage of transcripts in each score decile that align full-length with exonerate

#### accuracy with varying cutoff

- can find full set of loci that should have assembled by mapping reads to genomes, take set of all loci with reads mapping


- true postives: assembled with high score, mapped to genome
- false positives: assembled with high score, not mapped to genome
- false negatives: assembled with low score, mapped to genome
- true negatives: assembled with low score, not mapped to genome

calculate the Matthews correlation coefficient, plot it for a range of cutoffs

- could discuss what cutoff value for score maximises the Matthews correlation coefficient
