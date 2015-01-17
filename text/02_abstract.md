# Abstract

Improvements in short-read sequencing technology combined with rapidly decreasing prices have enabled the use of RNA-seq to assay the transcriptome of species whose genome has not been sequenced.

*De-novo* transcriptome assembly attempts to reconstruct the original transcript sequences from short reads.

Such transcriptome assemblies are relied upon for gene expression studies, phylogenetic analyses, and molecular tooling.

It is therefore important to ensure that assemblies are as accurate as possible, but to date there are few published tools for deep quality assessment of de-novo transcriptome assemblies, and none using paired-end read information.

We present **transrate**, an open source command-line program and library implemented in the Ruby and C languages that automates deep analysis of transcriptome assembly quality.

Transrate evaluates assemblies based on inspecting contigs, paired-read mapping, and optionally comparison to reference sequences with an extensive suite of established and novel metrics.

We introduce the **transrate score**: a novel summary statistic based on an explicit, intuitive statistical model of the transcriptome that captures many aspects of assembly quality.

Individual contigs and entire assemblies can be scored, enabling quality filtering of contigs and comparison and optimisation of assemblies.

We demonstrate using published data that the transrate score identifies the strengths and weaknesses of different assembly strategies and accurately classifies contigs.

Uniquely, the components of the transrate score quantify specific common problems with individual contigs, allowing the identification of subsets of contigs that can be improved by post-processing, and those that are already suitable for downstream analysis.

Here we present transrate… Our aim is not to compare and contrast exiting assembly software but to provide an independent method for assessing the quality of the de novo transcriptome assemblies that are produced in the absence of a genome reference.
