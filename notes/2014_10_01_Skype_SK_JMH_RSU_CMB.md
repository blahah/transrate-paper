## SK skype

## ground truth

for humans, take the CCDS set of transcripts - only one gene model per gene
could also try RefSeq

Ensembl for mice, also try it for humans

Rice use Phytozome

Yeast use official

take examples of things with high transrate scores and find out why they aren't aligning to the genome - use blat against the genome

another alternative is scpio, or bwa-mem

"using a set of reference gene models prevents discovery of real biological novelty"

## contig score

now the product of the components


## fig 4

maybe include a plot showing number of transcripts with > 0.5

## all figures

change 'contig score' to P(contig)


## next steps

focus on getting the score implemented

then do the blatting to get ground truth

for the TSA assemblies only take ones with <4GB of reads
