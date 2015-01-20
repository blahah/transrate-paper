# Methods

## Transrate

### Overview

transrate takes as input one or more transcriptome assemblies generated from the same set of paired-end reads, and the reads used to generate the assemblies.

Analysis proceeds by aligning the reads to the assemblies. For reads with multiple alignments within an assembly, only the most likely alignment is chosen. For each contig, the reads aligning to it are inspected to accumulate the components of the contig score. The assembly score is calculated using the contig scores and the full set of reads and alignments, including reads that did not align. Finally, contigs are classified according to whether they are (a) well-assembled, poorly assembled but could be improved by either (b) scaffolding, (c) chimera splitting, (d) reassembly or (d) poorly assembled and unable to be improved.

### Implementation

Transrate is written in Ruby and C++. It is open source, released under the MIT license. Code is available at http://github.com/Blahah/transrate, while help and full documentation are available at http://hibberdlab.com/transrate. The code is fully covered by automated tests. The software is operated via a user-friendly command line interface and can be used on OSX and linux.

### Read alignment and assignment

Reads are aligned to each assembly using SNAP v1.0.0.dev67 [@zaharia_faster_2011]. Alignments are reported up to a maximum edit distance of 30. Up to 10 multiple alignments are reported per read where available (`-omax 10`), up to a maximum edit distance of 5 from the best-scoring alignment (`-om 5`). Exploration within an edit distance of 5 from each alignment is allowed for the calculation of MAPQ scores (`-D 5`).

BAM-format alignments produced by SNAP are passed to Salmon (part of the Sailfish suite, [@patro_sailfish_2014]) to assign multi-mapping reads to their most likely contig of origin.

## The transrate score

We developed a reference-free statistical measure of assembly quality, the transrate score.

An assembly consists of a set of contigs $C$ derived from a set of reads $\hat{R}$. Reads are aligned and assigned to contigs such that $\forall c_i \in C, \exists R_i \in \hat{R} : R_i$ is the set of reads assigned to $c_i$.

### For contigs

We model a perfect contig as:

1. being a representation of a single transcript such that:
  a. each base in the contig must be derived from only one transcript
  b. all bases in the contig must be derived from the same transcript
2. unambiguously and accurately representing the identity of each base in the transcript
3. being structurally accurate and complete, such that the ordering of bases in the contig faithfully recreates the ordering of bases in the transcript

The transrate contig score is an estimate of the probability that a contig is perfect, i.e. meets all these criteria, using the aligned, assigned reads as evidence. We estimate the contig score $p(c_i)$ by taking the product of the probability of the components $S_1..S_4$, mapping to the criteria above.

To estimate our confidence $p(S_1)$ that each base in the contig is derived from a single transcript, we use the alignment edit distance, i.e. the number of changes that must be made to a read in order for it to perfectly match the contig sequence. We denote the edit distance of an assigned read $r_{ij} \in R_i$ as $e_{r_{ij}}$ and the set of reads that cover base $k$ ($k \in [1,n]$) as $\varrho k$. The maximum possible edit distance for alignment is fixed by the aligner, denoted as $\hat{e}$. Then the probability $p(b)$ that a base is derived from a single transcript is estimated as the arithmetic mean of $1 - \frac{e_{r_{ij}}}{\hat{e}}$ for each $r_{ij} \in \varrho k $, and the probability $p(S_1)$ that each base in a contig is derived from a single transcript is then the root mean square of $p(b)$.

We adapt the Bayesian segmentation algorithm of @liu_bayesian_1999 to estimate $p(S_2)$, our confidence that all bases in a contig derive from the same transcript. We assume that a contig that represents a single transcript will have a read coverage related to the expression level of that transcript in the sequenced sample. A contig that is a chimera derived from concatenation two or more transcripts will have multiple levels of read coverage representing the expression levels of its component transcripts. We therefore approximate $p(S_2)$ by the probability that the read coverage over a contig has a single level. To make the computation tractable, we further simplify the problem by treating the read coverage along the contig as a sequence of letters in an unordered alphabet. We achieve this representation by discretising the coverage at each base by taking its base-2 logarithm, rounded to the nearest integer. $p(S_2)$ can then be stated as the probability that the sequence of coverage values does not change composition at any point along its length, i.e. that it is composed of a single composition segment. The Liu and Lawrence (1999) algorithm is applied to find this probability.

Whether the contig accurately represents base identity of the transcript of origin is partially captured in $p(S_1)$ for bases that have reads assigned to them. We thus capture the missing information required to include this confidence in the score as $p(S_3)$, which is estimated as the proportion of bases that are supported by assigned reads.

Confidence in the structural accuracy and completeness of a contig, $p(S_3)$, is estimated using the pairing information of reads. We classify alignments of read pairs according to whether they are biologically plausible if we assume that the contig is structurally accurate and complete. Thus a read pair must meet all the following criteria to be valid: (a) both reads in the pair align to the same contig, (b) in an orientation that matches the sequencing protocol, (c) within a plausible distance given the fragmentation and size selection applied in the sequencing protocol. $p(S_3)$ is then approximated by the proportion of reads $R_i$ that are assigned to a contig that are valid.


### The assembly score

The assembly score captures the fact that a well-assembled transcriptome:

- is made up of high-quality contigs (and thus has high per-contig scores)
- is complete (and thus incorporates a high proportion of the experimental evidence)

Our confidence $q_A$ in the quality of an assembly can therefore be expressed as:

$$q_A=\sqrt{\left(\prod_{c=1}^nq_c\right)^\frac{1}{n}good(R)}$$

## Evaluation using published assemblies

To evaluate the transrate algorithm, we opted to use data from previously published assembly papers. Two different strands of analysis were performed: a detailed evaluation of the algorithm using ten assemblies from four species, and a broader survey of the range of assembly scores achievable using the entire NCBI Transcriptome Shotgun Archive.

### Detailed algorithm evaluation

#### Using real data

To evaluate the contig and assembly scores using real data, we used transrate to analyse assemblies from two previous publications: @xie_soapdenovo-trans:_2014, and @davidson_corset:_2014.

From @xie_soapdenovo-trans:_2014, assemblies were available for rice (*Oryza sativa*) and mouse (*Mus musculus*) that had been assembled using Oases, Trinity, and SOAPdenovo-Trans. From @davidson_corset:_2014, assemblies were available for human (*Homo sapiens*) and yeast (*Saccharomyces cerevisiae*) that had been assembled with Oases and Trinity.

These assemblies were chosen because they represent a phylogenetically diverse range of species assembled with several assemblers, with the read data and the transcriptome assemblies available to download, and with a relatively well-annotated reference genome available for each species.

Transrate was run separately for each species, with the full set of reads and all assemblies for that species as input.

For the pre-made assemblies, we generated a reference-based score for each contig in each of the ten assemblies. A reference dataset was compiled by including all transcripts plus any non-coding RNAs described in the reference annotation for each species.

Contigs were compared to the reference dataset by nucleotide-nucleotide local alignment with BLAST+ blastn version 2.2.29 [@camacho_blast+:_2009]. Because no genome annotation is complete, de-novo transcriptome assemblies are likely to contain contigs that are well-assembled representations of real transcripts not present in the reference. We therefore only considered contigs for score comparison if they aligned successfully to at least one reference transcript.

Each contig that has at least one hit was given a reference score by selecting the alignment with the lowest bitscore for each contig, then taking the product of the proportion of the reference covered, the proportion of the query covered, and the identity of the alignment.

#### Using simulated data

We generated reads by simulated sequencing for each of the four species (rice, mouse, human and yeast) using flux-simulator v1.2.1 [@griebel_modelling_2012]. For each species, a total of 10 million mRNA molecules were simulated from across the full set of annotated mRNAs from the Ensembl annotation with a random (exponentially distributed) expression distribution. mRNA molecules were uniform-randomly fragmented and then size-selected to a mean of 400 and standard distribution of 50. From the resulting fragments, 8 million 100bp paired-end reads were simulated using a learned error profile from real Illumina reads.

Two assemblies were generated from each set of simulated reads, one using Oases and another using SOAPdenovo-trans.

Accuracy was evaluated as for real data, except that all contigs (including those that did not align) were incorporated into the accuracy calculation.

### Assembly score survey

A survey of the range of achievable assembly scores was conducted by analysing transcriptome assemblies from the Transcriptome Shotgun Archive (http://www.ncbi.nlm.nih.gov/genbank/tsa). Entries in the archive were filtered to retain only those where paired-end reads were provided, the assembler and species were named in the metadata, and the number of contigs was at least 5,000. For the retained entries, the assembly and reads were downloaded, and transrate run to produce the assembly score for each entry.
