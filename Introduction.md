# Introduction

The use of RNA-seq for de-novo transcriptome assembly is a complex procedure, but if done well can yield valuable, high throughput biological insights at relatively low cost (e.g. \cite{http://dx.doi.org/10.1371/journal.pgen.1004365}). The analytical pipeline might include inspecting reads, trimming adapters amd low quality bases, read error correction, digital normalization, assembly and post-assembly improvements. Because the computational problems involved in these steps are hard to solve, there are many competing approaches, and because each organism has unique genomic properties, the algorithms need to be selected and tuned carefully for each experiment.

* explosion of assay-by-sequencing
* multitude of transcriptome assembly tools
* genomic and transcriptomic architecture varies widely between organisms and clades
* need for standards by which to evaluate transcriptome assemblies
* brief description of transrate