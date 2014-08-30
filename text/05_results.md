## Results

In order to examine the validity and utility of the transrate method we examined its performance on a variety of existing transcriptome assemblies from previous publications.

### Transrate gives unprecedented detail about the quality of a transcriptome assembly

We obtained de-novo transcriptome assemblies and their accompanying paired-end RNAseq reads for four species with good quality genome assemblies: human and yeast from *corset_paper; mouse and rice from *soapdt_paper. For all four species assemblies made using Trinity and Oases were available. For mouse and rice, SOAPdenovo-trans assemblies were also available. The assemblies used are summarised in table 1.

Figure 2 shows the basic reference-free metrics reported for these assemblies in their original publications. Using these metrics the performance of the assemblers appears to be XXX. By comparison, the metrics reported by transrate enable a deeper understanding of the qualities of these assemblies.

We analysed all assemblies for each species using transrate to generate contig, read, and reference-based metrics, as well as per-contig and per-assembly transrate scores. For each assembly two published genome-derived proterome references were provided to transrate: from the species under investigation, and from a closely related species. The analysis is summarised in table 2.

TODO:

- Something about how the metrics reported by transrate help understand the flaws in the assembly.
- Describe the results.

### Transrate indicates an assembly improvement strategy

The transrate metrics provide a clear indication of next steps to improve an assembly. In particular, they quantify to what extent the following actions will produce improvement:

1. Scaffolding and gap-filling.
2. Chimera splitting.
3. Assembly merging.
4. Read error correction.
5. Coverage normalisation.

### The reference-free transrate score accurately predicts true assembly quality.

In order to quantify the accuracy of the transrate score, for each contig in each assembly we sought to establish the ground-truth of whether it was an accurate reconstruction of a genome-encoded RNA product.

Because RNAseq reads capture not only protein-coding sequences, but also lncRNAs and other RNAs, we performed gapped alignment of contigs directly to the genome reference using exonerate. This allowed complete specification of accuracy as follows:

- We considered contigs with high transrate scores and full-length alignments, with gaps corresponding to annotated introns, to be true positives.
- Contigs that had high transrate scores but did not align full-length, or which contained introns, were considered to be false positives.
- Contigs with a low transrate score that did not map well to the genome were considered true negatives.
- Contigs with a low transrate score that mapped successfully to the genome were classed as false negatives.

### Filtering contigs by transrate score produces high-quality assemblies.

Something about the quality of the assemblies pre and post- filtering.

### Massive-scale analysis of assemblies provides guidance for using the transrate score.

To provide examples of real datasets and scores we downloaded all publicly available assembled transcriptomes that are available on the NCBI Transcriptome Shotgun Assembly database (ftp://ftp.ncbi.nlm.nih.gov/genbank/tsa/). Assemblies from this database were selected only if the following criteria were met:

1. The assembly program was listed.
2. Raw, paired-end reads were available for download.
3. The final assembly contained at least 5000 transcripts.

TODO:

- describe the overall distribution of transrate scores - what makes a good score?
- does the score differ by assembly method?
- does it differ by phylogeny?

### General performance expectations

TODO

- how long does transrate take with various sizes of input and various settings?
