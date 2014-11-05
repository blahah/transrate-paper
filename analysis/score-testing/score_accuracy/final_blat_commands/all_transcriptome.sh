# HUMAN

blat transcriptomes/Homo_sapiens.GRCh38.cdna_all_plus_ncrna.fa assemblies/corset_extra_data/Human-Trinity/Trinity.fasta -noHead -trimT -trimHardA -fine -minIdentity=70 -oneOff=1 blat_transcriptome/human_trinity_transcriptome.psl &

blat transcriptomes/Homo_sapiens.GRCh38.cdna_all_plus_ncrna.fa assemblies/corset_extra_data/Human-Oases/Oases.fasta -noHead -trimT -trimHardA -fine -minIdentity=70 -oneOff=1 blat_transcriptome/human_oases_transcriptome.psl &

# YEAST

blat transcriptomes/Saccharomyces_cerevisiae.R64-1-1.cdna_all_plus_ncrna.fa assemblies/corset_extra_data/Yeast-Trinity/Trinity.fasta -noHead -trimT -trimHardA -fine -minIdentity=70 -oneOff=1 blat_transcriptome/yeast_trinity_transcriptome.psl &

blat transcriptomes/Saccharomyces_cerevisiae.R64-1-1.cdna_all_plus_ncrna.fa assemblies/corset_extra_data/Yeast-Oases/Oases.fasta -noHead -trimT -trimHardA -fine -minIdentity=70 -oneOff=1 blat_transcriptome/yeast_oases_transcriptome.psl &

# MOUSE

blat transcriptomes/Mus_musculus.GRCm38.cdna_all_plus_ncrna.fa assemblies/SOAPdenovo-Trans_Supplementary_Assemblies/Assembly_script_result/Mouse_large/Oases/transcripts.fa -noHead -trimT -trimHardA -fine -minIdentity=70 -oneOff=1 blat_transcriptome/mouse_oases_transcriptome.psl &

blat transcriptomes/Mus_musculus.GRCm38.cdna_all_plus_ncrna.fa assemblies/SOAPdenovo-Trans_Supplementary_Assemblies/Assembly_script_result/Mouse_large/Trinity/transcripts.fa -noHead -trimT -trimHardA -fine -minIdentity=70 -oneOff=1 blat_transcriptome/mouse_trinity_transcriptome.psl &

blat transcriptomes/Mus_musculus.GRCm38.cdna_all_plus_ncrna.fa assemblies/SOAPdenovo-Trans_Supplementary_Assemblies/Assembly_script_result/Mouse_large/SOAPdenovo-Trans/transcripts.fa -noHead -trimT -trimHardA -fine -minIdentity=70 -oneOff=1 blat_transcriptome/mouse_soap_transcriptome.psl &

# RICE

blat transcriptomes/Osativa_204_transcript.fa assemblies/SOAPdenovo-Trans_Supplementary_Assemblies/Assembly_script_result/Oryza_sativa_large/Trinity/transcripts.fa -noHead -trimT -trimHardA -fine -minIdentity=70 -oneOff=1 blat_transcriptome/rice_trinity_transcriptome.psl &

blat transcriptomes/Osativa_204_transcript.fa assemblies/SOAPdenovo-Trans_Supplementary_Assemblies/Assembly_script_result/Oryza_sativa_large/Oases/transcripts.fa -noHead -trimT -trimHardA -fine -minIdentity=70 -oneOff=1 blat_transcriptome/rice_oases_transcriptome.psl &

blat transcriptomes/Osativa_204_transcript.fa assemblies/SOAPdenovo-Trans_Supplementary_Assemblies/Assembly_script_result/Oryza_sativa_large/SOAPdenovo-Trans/transcripts.fa -noHead -trimT -trimHardA -fine -minIdentity=70 -oneOff=1 blat_transcriptome/rice_soap_transcriptome.psl &
