# Methods

## Overview

transrate takes as input one or more transcriptome assemblies generated from the same set of reads, the reads used to generate the assemblies, and optionally one or more proteome references.

Analysis proceeds by first analysing the assembled contigs themselves, then by aligning the reads to the assemblies and inspecting the alignments, and finally by comparing the each assembly to each reference. This is summarised in figure 1.

## Contig metrics.

TODO

- basic sequence composition
- ORFs

## Read-mapping metrics.

TODO

- good mapped reads
- coverage
- uniqueness

## Reference-based metrics.

TODO

- reference coverage
- assembly coverage

## The transrate score.

We developed a reference-free statistical measure of assembly quality, the transrate score. An assembly $A$ generated from a set of reads $R$ is composed of $n$ contigs, $c_1...c_n$, each of which is composed of $m$ bases, $b_1...b_m$, which can have values $a$, $c$, $g$, $t$, or $n$, where $n$ captures all ambiguous bases. A sequence has composition $\theta$, where $\theta_a$, $\theta_n$, etc. represent the proportion of bases made up of a specific base.

### For contigs

The per-contig score captures the fact that a well-assembled contig:

- has experimental evidence (in the form of read coverage) for all assembled bases
- is not completely contained within any other contig (and thus has a high overall mapQ score)
- has a known base at each position (this a high proportion of unambiguous bases)
- does not collapse information from multiple true transcripts (and thus has a low per-base edit distance)
- is assembled completely and without chimerism (and thus no reads aligning to it give evidence to the contrary)

Our confidence $q_c$ in the quality of a contig $c$ can therefore be expressed as:

$$q_c=\sqrt[5]{\left(\prod_{i=1}^ncov_{c_i}\right)^{\frac{1}{n}}\left(\prod_{i=1}^nmapq_{c_i}\right)^{\frac{1}{n}}\left(1-\theta_n\right)\left(1-\frac{\prod_{i=1}^R{1-edit(R_{c_i})}}{R}\right)\left(\frac{\prod_{i=1}^R{good(R_{c_i})}}{R}\right)}$$

TODO:
- choose a new letter for indexing bases in a contig - n is already number of contigs
- choose better notation for indexing the mapping reads

Or, the geometric mean of:

- the proportion of bases with coverage > 0
- the geometric mean of the RMS mapQ score at each base
- the proportion of bases that are unambiguous
- 1 - the mean edit distance per base for all reads mapping to the contig
- the proportion of reads mapping to the contig that have alignments giving positive evidence of contig assembly quality

### For assemblies

The assembly score captures the fact that a well-assembled transcriptome:

- is made up of high-quality contigs (and thus has high per-contig scores)
- is complete (and thus incorporates a high proportion of the experimental evidence)

Our confidence $q_A$ in the quality of an assembly can therefore be expressed as:

$$q_A=\sqrt{\left(\prod_{c=1}^nq_c\right)^\frac{1}{n}good(R)}$$

TODO:
- better notation for reads that map good


\sqrt[N]{\prod_{n=1}^N{c_n}}
