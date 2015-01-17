# Rationale

Main points:

 - transcriptome assembly is complex:
  - de-novo transcriptomics can be applied cheaply to any species, regardless of whether a genome reference eists. The genomic and transcriptomic properties of each species are different
  - the computational process of reconstructing transcripts from short reads is extremely hard, and an unsolved problem.thus there are many competing alorithmic approaches
  - data are messy, and may be contaminated
  - products of an assemble may needp further processing to increase their utility.
  - therefore there are many tools availably, many stpes in a pipeline
  while there are many tools available.
  - This necessitates the construction and comparison of a variety of approaches to each experiment
- but there are inadequate tools to assess and compare txome assemblies.
 - existing approaches to transcriptome assembly assessment fall short:
   - trying to use genome assembly metrics (e.g. N50)
   - using metrics that are inappropriate or flawed (e.g. comp to genome)
   - restricted to using single-end reads
   - produce a score that provides little insight about the assembly
- transrate provides a new approach
  - paired-end reads are used
  - probabilistic score constructed from components that carry meaningful information about the assembly strategy
  - score contigs and assemblies
   

The use of RNA-seq for de-novo transcriptome assembly is a complex procedure, but if done well can yield valuable, high throughput biological insights at relatively low cost (e.g. [*list a few nice transcriptomics papers]).

A transcriptome assembly pipeline might include inspecting reads, trimming adapters and low quality bases, read error correction, digital normalisation, assembly and post-assembly improvements such as scaffolding and clustering.

Because the computational problems involved in these steps are hard to solve [*cite], there are many competing approaches.

For example, popular tools for the assembly step include Trinity [*trinity], Oases [*oases], Trans-AbySS [*trans-abyss], and SOAPdenovo-Trans [*soapdt], among many others [*cite].

Furthermore, because each organism has unique genomic properties, the algorithms need to be selected and tuned carefully for each experiment.

These conditions demonstrate the need for a method to accurately judge the quality of transcriptome assemblies, but to date little attention has been paid to the subject.

By comparison, there are several tools for evaluating and interpreting the quality of genome assemblies.

- basic statistics and plots [*quast]
- explicit statistical model [*ALE, CGAL, assembly-eval]

In this work we describe our software for deep quality analysis of transcriptome assemblies, including the metrics and scoring methods. We demonstrate the accuracy of the method, and provide guidance for using the software and interpreting its results to compare and improve transcriptome assemblies.
