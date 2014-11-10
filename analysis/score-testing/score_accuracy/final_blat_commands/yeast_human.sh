#!/bin/bash

MAXINTRON_YEAST=10000
MAXINTRON_HUMAN=50000

# YEAST

YEAST_ASSEMBLIES="assemblies/corset_extra_data/Yeast"

blat \
genomes/Saccharomyces_cerevisiae.R64-1-1.dna_rm.toplevel.fa \
$YEAST_ASSEMBLIES-Oases/Oases.fasta \
-maxIntron=$MAXINTRON_YEAST \
-noHead \
-trimT \
-trimHardA \
-fine \
yeast_oases_genome.psl &

blat \
genomes/Saccharomyces_cerevisiae.R64-1-1.dna_rm.toplevel.fa \
$YEAST_ASSEMBLIES-Trinity/Trinity.fasta \
-maxIntron=$MAXINTRON_YEAST \
-noHead \
-trimT \
-trimHardA \
-fine \
yeast_trinity_genome.psl &

# HUMAN

HUMAN_ASSEMBLIES="assemblies/corset_extra_data/Human"

blat \
genomes/Homo_sapiens.GRCh38.dna_rm.primary_assembly.fa \
$HUMAN_ASSEMBLIES-Oases/Oases.fasta \
-maxIntron=$MAXINTRON_HUMAN \
-noHead \
-trimT \
-trimHardA \
-fine \
human_oases_genome.psl &

blat \
genomes/Homo_sapiens.GRCh38.dna_rm.primary_assembly.fa \
$HUMAN_ASSEMBLIES-Trinity/Trinity.fasta \
-maxIntron=$MAXINTRON_HUMAN \
-noHead \
-trimT \
-trimHardA \
-fine \
human_trinity_genome.psl &
