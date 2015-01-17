# Methods

## Transrate

### Overview

transrate takes as input one or more transcriptome assemblies generated from the same set of reads, and the reads used to generate the assemblies.

Analysis proceeds by aligning the reads to the assemblies. For reads with multiple valid alignments, only the most likely alignment within each assembly is chosen. For each contig, the reads aligning to it are inspected to accumulate the components of the contig score. The assembly score is calculated using the contig scores and the full set of reads and alignments, including reads that did not align. Finally, contigs are classified according to whether they are (a) well-assembled, poorly assembled but could be improved by either (b) scaffolding or (c) chimera splitting, or (d) poorly assembled and unable to be improved.

### Implementation

Transrate is written in Ruby and C++. It is open source, released under the MIT license. Code is available at github.com/Blahah/transrate, while help and full documentation are available at hibberdlab.com/transrate. The code is fully covered by automated tests.

### Read alignment and assignment

Reads are aligned to each assembly using SNAP v1.0.0.dev66 [cite snap]. Alignments are reported up to a maximum edit distance of 30. Up tp 10 multiple alignments are reported per read where available (`-omax 10`), up to a maximum edit distance of 5 from the best-scoring alignment (`-om 5`). Exploration within an edit distance of 5 from each alignment is allowed for the calculation of MAPQ scores (`-D 5`).

BAM-format alignments produced by SNAP are passed to Salmon (part of the Sailfish suite, [cite sailfish]) to assign multi-mapping reads to their most likely contig of origin.

## The contig score

We developed a reference-free statistical measure of assembly quality, the transrate score. An assembly $A$ generated from a set of reads $R$ is composed of $n$ contigs, $c_1...c_n$, each of which is composed of $m$ bases, $b_1...b_m$, which can have values $a$, $c$, $g$, $t$, or $n$, where $n$ captures all ambiguous bases. A sequence has composition $\theta$, where $\theta_a$, $\theta_n$, etc. represent the proportion of bases made up of a specific base.

### For contigs

The per-contig score captures the fact that a well-assembled contig:

- has experimental evidence (in the form of read coverage) for all assembled bases
- is not completely contained within any other contig (and thus has a high overall mapQ score)
- accurately represents the information in the reads (and thus has a low per-base edit distance)
- is assembled completely and without chimerism (and thus no reads aligning to it give evidence to the contrary)

Our confidence $q_c$ in the quality of a contig $c$ can therefore be expressed as:

$$q_c=
\sqrt[5]{
  \left(\prod_{i=1}^ncov_{c_i}\right)^{\frac{1}{n}}
  \left(1-\frac{\prod_{i=1}^R{1-edit(R_{c_i})}}{R}\right)
  \left(\frac{\prod_{i=1}^R{good(R_{c_i})}}{R}\right)}$$

TODO:
- choose a new letter for indexing bases in a contig - n is already number of contigs
- choose better notation for indexing the mapping reads

Or, the geometric mean of:

- the proportion of bases with coverage > 0
- the geometric mean of the RMS mapQ score at each base
- the proportion of bases that are unambiguous
- 1 - the mean edit distance per base for all reads mapping to the contig
- the proportion of reads mapping to the contig that have alignments giving positive evidence of contig assembly quality

### The assembly score

The assembly score captures the fact that a well-assembled transcriptome:

- is made up of high-quality contigs (and thus has high per-contig scores)
- is complete (and thus incorporates a high proportion of the experimental evidence)

Our confidence $q_A$ in the quality of an assembly can therefore be expressed as:

$$q_A=\sqrt{\left(\prod_{c=1}^nq_c\right)^\frac{1}{n}good(R)}$$

TODO:
- better notation for reads that map good


\sqrt[N]{\prod_{n=1}^N{c_n}}

## Evaluation using published assemblies

To evaluate the transrate algorithm, we opted to use data from previously published assembly papers. Two different strands of analysis were performed: a detailed evaluation of the algorithm using ten assemblies from four species, and a broader survey of the range of assembly scores achievable using the entire NCBI Transcriptome Shotgun Archive.

### Detailed algorithm evaluation

To evaluate the contig and assembly scores, we used transrate to analyse assemblies from two previous publications: [cite soapdenovotrans], and [cite corset].

From [soapdenovotrans] paper, assemblies were available for rice (Oryza sativa) and mouse (Mus musculus) that had been assembled using Oases [cite], Trinity [cite], and SOAPdenovo-Trans [cite]. From [corset], assemblies were available for human (Homo sapiens) and yeast (Saccharomyces cerevisiae) that had been assembled with Oases and Trinity.

These assemblies were chosen because they represent a phylogenetically diverse range of species assembled with several assemblers, with the read data and the transcriptome assemblies available to download, and with a relatively well-annotated reference genome available for each species.

Transrate was run separately for each species, with the full set of reads and all assemblies for that species as input.

#### Contig score accuracy evaluation

To evaluate the accuracy of the contig score, we generated a reference-based score for each contig in each of the ten assemblies. A reference dataset was compiled by including all transcripts plus any non-coding RNAs described in the reference annotation for each species.

Contigs were compared to the reference dataset by nucleotide-nucleotide alignment with BLAST+ blastn version 2.2.29 [cite blast+]. Because no genome annotation is complete, de-novo transcriptome assemblies are likely to contain contigs that are well-assembled representations of real transcripts not present in the reference. We therefore only considered contigs for score comparison if they aligned successfully to at least one reference transcript.

Each contig that has at least one hit was given a reference score by selecting the alignment with the lowest bitscore for each contig, and multiplying the proportion of the reference that was covered by the alignment by the identity of the alignment to produce a score between 0 and 1. This score corresponds to the proportion of reference bases found in the contig.

Accuracy was evaluated in

### Assembly score survey

A survey of the range of achievable assembly scores was conducted by analysing transcriptome assemblies from the Transcriptome Shotgun Archive.
