## Results and discussion

### Transrate is software for deep quality analysis of transcriptome assemblies

We have developed Transrate, a method for detailed quality analysis of whole transcriptome assemblies and their constituent contigs without a reference. Transrate uses only the contigs themselves and the paired-end reads used to generate them as evidence. Here we present the Transrate method. First we describe the Transrate contig and assembly scores, with a focus on how they can be used to identify misassemblies, select the most useful information from the assembly, and to improve and compare assemblies. Next, we perform experiments using real and simulated data across a range of species to evaluate the accuracy and usefulness of the method, and demonstrate its improvement over existing methods.

![The Transrate workflow. (1.) Transrate takes as input one or more de-novo transcriptome assemblies and the paired-end reads used to generate them. (2.) The reads are aligned to the contigs with SNAP, and multi-mapping reads are assigned to their most likely contig of origin with Salmon. (3.) The assigned alignments are examined to measure per-base coverage and edit distance for each contig, and the proportion of reads mapping to each contig that agree with the contig structure. Per-base coverage is analysed to determine segmentation. (4.) Score components are combined to score each contig. (5.) Contig scores are combined with the full set of reads and alignments to score the entire assembly. (6.) Contigs are classified according to whether they are well-assembled, poorly assebled and unfixable, or poorly assembled and fixable by either reassembly, chimera splitting, or targeted scaffolding. ](../figures/figure_1/transrate_pipeline_figure_square.png)

### The Transrate scores evaluate confidence in contigs and assemblies

In transcriptome assembly experiments, the aim is the reconstruct as accurate a representation as possible of the true set of mRNAs present in biological sample. However, due to errors and noise in the sequencing process, incomplete coverage of all transcripts due to low expression or insufficient sequencing depth, and the computational complexity of assembly, an assembly is an imperfect reconstruction. The aim of transrate is to enable iterative improvements towards a perfect assembly, regardless of the assembly pipeline used, and to quantify confidence in any given assembly or contig. Because the vast majority of transcrptomics experiments currently use Illumina paired-end sequencing, Transrate is focused on data of this type, although the method could be expanded to other types of sequencing.

Transcriptome assemblies tend to contain characteristic errors that result from methodological constraints. The transrate contig score components are designed to quantify these errors:

**Gene family collapse**. Transcripts from different genes in a family, from haplotypes, or from gene copies share a high level of sequence identity. The heuristics used by assemblers to avoid assembling read errors can also lead to this true biological information being collapsed, by outputting a single contig from reads that in reality originated from multiple similar transcripts. If groups of such contigs can be separated from the rest of the assembly, they could be reassembled using more relaxed heuristics to achieve a better representation of the source transcripts.

**Chimeras**. Regions of repetitive sequence that are shared between multiple transcripts, especially in the polyA tails or UTRs, can be difficult for assemblers to distinguish from geniune connectivity. It is therefore common to find that a contig contains two or more otherwise well-assembled transcripts that have been concatenated together. If these contigs can be identified, they can be examined and split at the point of concatenation to recover the useful biological information.

**Fragmentation**. Low coverage regions within a sequenced transcript can result from various phenomena including low sequencing depth, low abundance transcripts, and high or low complexity in the original sequence. Whatever the cause, low coverage can lead to incomplete assembly of a transcript, so that the transcript is present in several separate, non-overlapping contigs. Using the pairing of reads, it is common practise to scaffold these fragments. However, in our experience many scaffolded assemblies still contain them. By identifying all the contigs that might benefit from scaffolding, targetting scaffolding can be applied to improve contiguity.

Transrate evaluates each contig in an assembly to determine whether there is any evidence of these errors.


One aim of transrate is to allow the classification of contigs according to whether they are well-assembled.

### The segmentation score captures common assembly mistakes

- show evidence from yeast

### Contigs can be classified by transrate score

### Transrate gives unprecedented detail about the quality of a de-novo transcriptome assembly

We obtained de-novo transcriptome assemblies and their accompanying paired-end RNAseq reads for four species with good quality genome assemblies: human and yeast from *corset_paper; mouse and rice from *soapdt_paper. For all four species assemblies made using Trinity and Oases were available. For mouse and rice, SOAPdenovo-trans assemblies were also available. The assemblies used are summarised in table 1.

Figure 2 shows the basic reference-free metrics reported for these assemblies in their original publications. Using these metrics the performance of the assemblers appears to be XXX. By comparison, the metrics reported by transrate enable a deeper understanding of the qualities of these assemblies.

We analysed all assemblies for each species using transrate to generate contig, read, and reference-based metrics, as well as per-contig and per-assembly transrate scores. For each assembly, the full set of cDNAs from the latest Ensembl annotation was used as a reference.

TODO:

- Something about how the metrics reported by transrate help understand the flaws in the assembly.
- Describe the results.

### Transrate indicates a within assembly improvement strategy

The transrate metrics provide a clear indication of next steps to improve an assembly. In particular, they quantify to what extent the following actions will produce improvement:

1. Discarding low-quality contigs
2. Scaffolding and gap-filling
3. Chimera splitting.

### The reference-free transrate score accurately predicts true assembly quality.

In order to quantify the accuracy of the transrate score, for each contig in each assembly we sought to establish whether it was an accurate reconstruction of a genome-encoded RNA product.

Because RNAseq reads capture not only protein-coding sequences, but also lncRNAs and other RNAs, we first sought to discover the true set of genome-encoded RNA products represented in each RNAseq dataset. For each species, we aligned the RNAseq reads to the genome and performed a genome-guided assembly of the aligned reads to extend the existing annotation. We then filtered the annotations to remove those with no reads mapping.

For each assembly, we performed gapped alignment of contigs directly to the genome reference using exonerate. Contigs were classified as 'complete' if they aligned full-length to an annotated feature, with gaps corresponding to annotated introns. This allowed complete specification of accuracy as depicted in table 3:

| --              | Genome-based assessment |
| ------------------------------------------|
| Transrate score | Complete  | Incomplete  |
| ------------------------------------------|
| High            | TP        | FP          |
| Low             | FN        | TN          |

Using this scheme we evaluated precision, recall and accuracy for each assembly (figure 6). Transrate score was strongly correlated with genome-based completeness (figure 6a).

To evaluate the predictive power of transrate scores, we varied the cutoff for 'high' transrate scores (figure 6). In all cases, the maximum accuracy was > [SOME NUMBER], with precision and recall in the ranges of [V-X] and [Y-Z].

### Transrate enables optimisation across the assembler parameter space


### Transrate is faster than existing approaches

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
