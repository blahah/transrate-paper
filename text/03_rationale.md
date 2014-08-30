# Rationale

The use of RNA-seq for de-novo transcriptome assembly is a complex procedure, but if done well can yield valuable, high throughput biological insights at relatively low cost (e.g. [*aubry-2014]).

The analytical pipeline might include inspecting reads, trimming adapters and low quality bases, read error correction, digital normalisation, assembly and post-assembly improvements such as scaffolding and clustering.

Because the computational problems involved in these steps are hard to solve, there are many competing approaches.

For example, popular tools for the assembly step include Trinity [*trinity], Oases [*oases], Trans-AbySS [*trans-abyss], and SOAPdenovo-Trans [*soapdt], among many others.

Furthermore, because each organism has unique genomic properties, the algorithms need to be selected and tuned carefully for each experiment.

These conditions demonstrate the need for a method to accurately judge the quality of transcriptome assemblies, but to date little attention has been paid to the subject.

In this work we describe our software for deep quality analysis of transcriptome assemblies, including the metrics and scoring methods. We provide guidance for using the software and interpreting its results to compare and improve transcriptome assemblies.
