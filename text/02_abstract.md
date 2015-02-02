# Abstract

Improvements in short-read sequencing technology combined with rapidly decreasing prices have enabled the use of RNA-seq to assay the transcriptome of species whose genome has not been sequenced.

*De-novo* transcriptome assembly attempts to reconstruct the original transcript sequences from short reads.

Such transcriptome assemblies are relied upon for gene expression studies, phylogenetic analyses, and molecular tooling.

It is therefore important to ensure that assemblies are as accurate as possible, but to date there are few published tools for deep quality assessment of de-novo transcriptome assemblies, and none that allow the identification of useful parts of an assembly.

We present **transrate**, an open source command-line program that automates deep analysis of transcriptome assembly quality.

Transrate evaluates assemblies based on inspecting contigs, paired-read mapping, and optionally comparison to reference sequences with an extensive suite of established and novel metrics.

We introduce the **transrate scores**: novel summary statistics based on an explicit, intuitive statistical model of transcriptome assembly that captures many aspects of assembly quality.

Individual contigs and entire assemblies can be scored, enabling quality filtering of contigs and comparison and optimisation of assemblies.

Uniquely, the components of the transrate score quantify specific common problems with individual contigs, allowing the identification of subsets of contigs that can be improved by post-processing, and those that are already suitable for downstream analysis.

We demonstrate using real and simulated data that the transrate score accurately assesses contig and assembly quality, identifies the strengths and weaknesses of different assembly strategies, and classifies contigs.
