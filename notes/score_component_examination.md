## Examination of contig score components

### Segmentation

Took 30 contigs with lowest score on segmentation componenent.

Aligned to reference transcriptome with blastn.

A chimera consisting of two or more transcripts joined together should have at least two non-overlapping hits.

| Contig name       | Component score | No. blast hits e-value < 1.0E-5 | No. non-overlapping hit clusters | Chimera? |
|-------------------|-----------------|---------------------------------|----------------------------------|----------|
| comp2222_c0_seq1  | 0.0227069       | 3                               | 2                                | y        |
| comp3736_c0_seq1  | 0.0272455       | 2                               | 1                                | n        |
| comp2527_c0_seq1  | 0.0319697       | 1                               | 1                                | n        |
| comp2420_c1_seq1  | 0.032394        | 2                               | 1                                | n        |
| comp3779_c0_seq1  | 0.0354787       | 3                               | 2                                | y        |
| comp3698_c0_seq1  | 0.0360604       | 1                               | 1                                | n        |
| comp2292_c0_seq1  | 0.0363797       | 4                               | 4                                | y        |
| comp3016_c0_seq1  | 0.0372161       | 0                               | 0                                | n        |
| comp3414_c0_seq1  | 0.0374644       | 0                               | 0                                | n        |
| comp3669_c0_seq1  | 0.0382478       | 2                               | 2                                | y        |
| comp2338_c0_seq1  | 0.0384125       | 2                               | 2                                | y        |
| comp3807_c0_seq1  | 0.0408429       | 6                               | 2                                | y        |
| comp3097_c1_seq1  | 0.0423488       | 1                               | 1                                | n        |
| comp3665_c2_seq32 | 0.0433364       | 29                              | 1                                | n        |
| comp4106_c0_seq1  | 0.04354         | 2                               | 2                                | y        |
| comp2456_c0_seq3  | 0.0442376       | 3                               | 1                                | n        |
| comp2386_c0_seq1  | 0.0453477       | 0                               | 0                                | n        |
| comp3685_c0_seq1  | 0.0456716       | 2                               | 2                                | y        |
| comp2060_c0_seq1  | 0.0464549       | 5                               | 2                                | y        |
| comp3448_c2_seq1  | 0.0464656       | 2                               | 2                                | y        |
| comp3533_c0_seq3  | 0.0470728       | 2                               | 1                                | n        |
| comp3191_c0_seq1  | 0.0472406       | 3                               | 2                                | y        |
| comp3600_c1_seq1  | 0.0472648       | 3                               | 2                                | y        |
| comp3377_c0_seq1  | 0.0480058       | 17                              | 1                                | n        |
| comp3432_c0_seq1  | 0.0480142       | 2                               | 1                                | n        |
| comp2320_c0_seq1  | 0.0483607       | 4                               | 3                                | y        |
| comp4240_c0_seq1  | 0.0491625       | 6                               | 2                                | y        |
| comp3252_c0_seq1  | 0.0494757       | 2                               | 1                                | n        |
| comp3256_c0_seq1  | 0.0496263       | 4                               | 3                                | y        |
| comp3179_c1_seq1  | 0.0501237       | 9                               | 4                                |          |

Summary:

- 3/30 have no hits
- 15/27 contigs with hits are clear chimeras
- the other 12 appear to be a well-assembled transcript, joined to a run of bases that don't match the reference at all

### Sequence identity correctness

Took 30 contigs with lowest score on sequence identity correctness.

Aligned to reference transcriptome and genome with blastn.

Contigs that are collapsed representations of multiple transcripts or genes should have multiple high-confidence hits against either the transcriptome or the genome.

| Contig name        | Component score | Transcriptome hits | Genome hits | Evidence of family collapse? |
|--------------------|-----------------|--------------------|-------------|------------------------------|
| comp3423_c0_seq1   | 0.582011        | 1                  | 1           | n                            |
| comp309149_c0_seq1 | 0.590062        | 1                  | 1           | n                            |
| comp3111_c0_seq1   | 0.613061        | 2                  | 2           | y                            |
| comp3113_c1_seq1   | 0.648485        | 4                  | 15          | y                            |
| comp272622_c0_seq1 | 0.68            | 1                  | 0           | n                            |
| comp24393_c0_seq1  | 0.690476        | 0                  | 2           | y                            |
| comp3600_c0_seq2   | 0.694456        | 0                  | 16          | y                            |
| comp3665_c1_seq1   | 0.700608        | 94                 | 13          | y                            |
| comp143163_c0_seq1 | 0.707692        | 24                 | 0           | y                            |
| comp129162_c0_seq1 | 0.710714        | 0                  | 0           | ?                            |
| comp3009_c0_seq1   | 0.724762        | 9                  | 16          | y                            |
| comp3423_c0_seq3   | 0.728323        | 1                  | 1           | n                            |
| comp3562_c0_seq2   | 0.731746        | 0                  | 0           | ?                            |
| comp156421_c0_seq1 | 0.744643        | 5                  | 16          | y                            |
| comp3640_c0_seq5   | 0.75            | 1                  | 3           | y                            |
| comp111546_c0_seq1 | 0.753571        | 0                  | 0           | ?                            |
| comp191305_c0_seq1 | 0.758095        | 0                  | 0           | ?                            |
| comp1463_c0_seq1   | 0.758442        | 0                  | 0           | ?                            |
| comp3603_c4_seq2   | 0.762247        | 12                 | 16          | y                            |
| comp3654_c0_seq16  | 0.768           | 0                  | 1           | n                            |
| comp505_c0_seq1    | 0.771429        | 0                  | 6           | y                            |
| comp277323_c0_seq1 | 0.771429        | 0                  | 0           | ?                            |
| comp162548_c0_seq1 | 0.77551         | 0                  | 0           | ?                            |
| comp189983_c0_seq1 | 0.777778        | 0                  | 0           | ?                            |
| comp157164_c0_seq1 | 0.781633        | 0                  | 0           | ?                            |
| comp3637_c1_seq2   | 0.782032        | 4                  | 4           | y                            |
| comp201694_c0_seq1 | 0.783673        | 0                  | 0           | ?                            |
| comp260862_c0_seq1 | 0.790476        | 0                  | 0           | ?                            |
| comp256546_c0_seq1 | 0.795238        | 0                  | 1           | ?                            |
| comp270985_c0_seq1 | 0.796429        | 2                  | 1           | y                            |

Summary:

- 12/30 have no hits and thus cannot be evaluated
- 13/18 of those with hits have multiple hits in either the transcriptome or the genome, suggesting possible family collapse

### Structural correctness

Took 30 lowest scoring contigs on structural correctness that had non-zero coverage.

Contigs with structural problems should either have no hit, or hit only a small portion of a reference contig.

| Contig name      | Component score | Number of hits | % of reference covered by hit | Evidence of structural problems? |
|------------------|-----------------|----------------|-------------------------------|----------------------------------|
| comp53_c0_seq1   | 0               | 0              | na                            | y                                |
| comp233_c0_seq1  | 0               | 0              | na                            | y                                |
| comp356_c0_seq1  | 0               | 0              | na                            | y                                |
| comp399_c0_seq1  | 0               | 0              | na                            | y                                |
| comp443_c0_seq1  | 0               | 0              | na                            | y                                |
| comp578_c0_seq1  | 0               | 0              | na                            | y                                |
| comp607_c0_seq1  | 0               | 0              | na                            | y                                |
| comp999_c0_seq1  | 0               | 0              | na                            | y                                |
| comp1080_c0_seq1 | 0               | 0              | na                            | y                                |
| comp1179_c0_seq1 | 0               | 0              | na                            | y                                |
| comp1210_c1_seq2 | 0               | 0              | na                            | y                                |
| comp1225_c0_seq1 | 0               | 1              | 14%                           | y                                |
| comp1233_c0_seq1 | 0               | 0              | na                            | y                                |
| comp1283_c0_seq1 | 0               | 0              | na                            | y                                |
| comp1395_c0_seq1 | 0               | 0              | na                            | y                                |
| comp1407_c0_seq1 | 0               | 0              | na                            | y                                |
| comp1463_c0_seq1 | 0               | 0              | na                            | y                                |
| comp1471_c0_seq1 | 0               | 0              | na                            | y                                |
| comp1518_c0_seq1 | 0               | 0              | na                            | y                                |
| comp2518_c1_seq1 | 0               | 0              | na                            | y                                |
| comp2520_c0_seq1 | 0               | 0              | na                            | y                                |
| comp2567_c0_seq1 | 0               | 0              | na                            | y                                |
| comp2578_c2_seq1 | 0               | 0              | na                            | y                                |
| comp2616_c1_seq1 | 0               | 0              | na                            | y                                |
| comp2651_c1_seq1 | 0               | 0              | na                            | y                                |
| comp2671_c0_seq1 | 0               | 0              | na                            | y                                |
| comp2858_c0_seq1 | 0               | 0              | na                            | y                                |
| comp2958_c0_seq2 | 0               | 0              | na                            | y                                |
| comp2976_c1_seq1 | 0               | 0              | na                            | y                                |
| comp2998_c0_seq1 | 0               | 0              | na                            | y                                |
