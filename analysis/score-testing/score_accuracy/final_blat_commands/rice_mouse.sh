#!/bin/bash

MAXINTRON_MOUSE=50000
MAXINTRON_RICE=20000

# MOUSE

MOUSE_ASSEMBLIES="assemblies/SOAPdenovo-Trans_Supplementary_Assemblies/Assembly_script_result/Mouse_large"

blat \
genomes/Mus_musculus.GRCm38.dna_rm.primary_assembly.fa \
$MOUSE_ASSEMBLIES/Oases/transcripts.fa \
-maxIntron=$MAXINTRON_MOUSE \
-noHead \
-trimT \
-trimHardA \
-fine \
mouse_oases_genome.psl &

blat \
genomes/Mus_musculus.GRCm38.dna_rm.primary_assembly.fa \
$MOUSE_ASSEMBLIES/Trinity/transcripts.fa \
-maxIntron=$MAXINTRON_MOUSE \
-noHead \
-trimT \
-trimHardA \
-fine \
mouse_trinity_genome.psl &

blat \
genomes/Mus_musculus.GRCm38.dna_rm.primary_assembly.fa \
$MOUSE_ASSEMBLIES/SOAPdenovo-Trans/transcripts.fa \
-maxIntron=$MAXINTRON_MOUSE \
-noHead \
-trimT \
-trimHardA \
-fine \
mouse_soap_genome.psl &

# RICE

RICE_ASSEMBLIES="assemblies/SOAPdenovo-Trans_Supplementary_Assemblies/Assembly_script_result/Oryza_sativa_large"

blat \
genomes/Osativa_204_hardmasked.fa \
$RICE_ASSEMBLIES/Oases/transcripts.fa \
-maxIntron=$MAXINTRON_RICE \
-noHead \
-trimT \
-trimHardA \
-fine \
rice_oases_genome.psl &

blat \
genomes/Osativa_204_hardmasked.fa \
$RICE_ASSEMBLIES/Trinity/transcripts.fa \
-maxIntron=$MAXINTRON_RICE \
-noHead \
-trimT \
-trimHardA \
-fine \
rice_trinity_genome.psl &

blat \
genomes/Osativa_204_hardmasked.fa \
$RICE_ASSEMBLIES/SOAPdenovo-Trans/transcripts.fa \
-maxIntron=$MAXINTRON_RICE \
-noHead \
-trimT \
-trimHardA \
-fine \
rice_soap_genome.psl &
