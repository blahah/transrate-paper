## Results

In order to examine the validity and utility of the transrate method we examined its performance on a variety of existing transcriptome assemblies from previous publications.

### Transrate score components are independent and uncorrelated


### Contigs can be classified by transrate score

### Transrate gives unprecedented detail about the quality of a de-novo transcriptome assembly

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

In order to quantify the accuracy of the transrate score, for each contig in each assembly we sought to establish whether it was an accurate reconstruction of a genome-encoded RNA product.

Because RNAseq reads capture not only protein-coding sequences, but also lncRNAs and other RNAs, we first sought to discover the true set of genome-encoded RNA products represented in each RNAseq dataset. For each species, we aligned the RNAseq reads to the genome and performed a genome-guided assembly of the aligned reads to extend the existing annotation. We then filtered the annotations to remove those with no reads mapping.

For each assembly, we performed gapped alignment of contigs directly to the genome reference using exonerate. Contigs were classified as 'complete' if they aligned full-length to an annotated feature, with gaps corresponding to annotated introns. This allowed complete specification of accuracy as depicted in table 3:

```
| --              | Genome-based assessment |
| ------------------------------------------|
| Transrate score | Complete  | Incomplete  |
| ------------------------------------------|
| High            | TP        | FP          |
| Low             | FN        | TN          |
```

Using this scheme we evaluated precision, recall and accuracy for each assembly (figure 6). Transrate score was strongly correlated with genome-based completeness (figure 6a).

To evaluate the predictive power of transrate scores, we varied the cutoff for 'high' transrate scores (figure 6). In all cases, the maximum accuracy was > [SOME NUMBER], with precision and recall in the ranges of [V-X] and [Y-Z].

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
