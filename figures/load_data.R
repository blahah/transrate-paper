## transrate figures - load data

data_dir <- "../data"

species_list <- as.factor(c('mouse', 'rice', 'human', 'yeast'))
assemblers <- c('trinity', 'oases', 'soapdenovotrans', 'merged')
datasets <- expand.grid(species_list, assemblers)
datasets <- apply(datasets, MARGIN = 2, FUN = as.character)

score_cols <- c('p_good', 'p_not_segmented', 'p_bases_covered',
                'p_seq_true', 'score',
                'length', 'coverage')
library(data.table)
wide_data <- data.table()
library(reshape2)
library(dplyr)
assembly_data <- data.table()

for (rowno in 1:nrow(datasets)) {
  # generate path to the contig files
  species <- datasets[rowno, 1]
  assembler <- datasets[rowno, 2]
  dirs <- c('..', 'data', species, 'transrate', assembler)
  path <- paste(dirs, collapse="/")
  if (!file.exists(path)) {
    next
  }

  # list all contig files and select the most recent one
  filelist <- list.files(path, pattern = "*contigs*")
  if (length(filelist) == 0) {
    next
  }
  files <- data.frame(file = paste(path,
                                   filelist,
                                   sep="/"),
                      stringsAsFactors = FALSE)
  files$mtime <- unlist(lapply(files$file, function(x){ file.info(x)$mtime}))
  mostrecent <- subset(files, mtime == max(files$mtime))$file[1]
  print(mostrecent)

  # load the most recent file and save the relevant columns
  csv <- fread(mostrecent)
  csv <- csv[, score_cols, with=F]
  csv[, species:=species]
  csv[, assembler:=assembler]
  wide_data <- rbind(wide_data, csv[complete.cases(csv),])

  # load the assembly data
  assdata_file <- paste(species, '-', assembler, '_assemblies.csv', sep='')
  assdata_path <- paste(path, assdata_file, sep='/')
  assdata <- fread(assdata_path)
  if (ncol(assdata) > 45) {
    assdata[, 41:57 := NULL, with=F]
  }
  assdata[, assembler:=assembler]
  assdata[, species:=species]
  assembly_data <- rbind(assembly_data, assdata)
}
wide_data[assembler == 'soapdenovotrans', assembler:='soap']
assemblers[3] <- 'soap'
wide_data[, species:=factor(species, levels=species_list)]
wide_data[, assembler:=factor(assembler, levels=assemblers)]
wide_data <- group_by(wide_data, assembler, species)
data <- melt(wide_data, id.vars = c('species', 'assembler', 'score',
                                    'length', 'coverage'),
             variable.name = 'score_component')

assembly_data[assembler == 'soapdenovotrans', assembler:='soap']
assembly_data[, species:=factor(species, levels=species_list)]
assembly_data[, assembler:=factor(assembler, levels=assemblers)]


spp <- c('mouse', 'rice', 'human', 'yeast')
assem <- c('trinity', 'oases', 'soap', 'merged')

cols <- c('contig_name', 'target', 'id', 'alnlen', 'mismatches', 'gaps',
          'qstart', 'qend', 'tstart', 'tend', 'evalue', 'bitscore',
          'qlen', 'tlen')

load_rbbs <- function(blast) {

  # first blast
  dt <- fread(paste(data_dir, blast, sep="/"))
  setnames(dt, cols)
  setkey(dt, contig_name)

  # second blast
  pathdirs <- strsplit(substr(blast, 1, nchar(blast)-8), "/")
  n_dirs <- length(pathdirs[[1]])
  pathcomps <- strsplit(pathdirs[[1]][n_dirs], "_into_")
  path <- paste(pathdirs[[1]][1:(n_dirs-1)], collapse="/")
  blast2 <- paste(pathcomps[[1]][2], "_into_", pathcomps[[1]][1], ".2.blast", sep="")
  dt2 <- fread(paste(data_dir, path, blast2, sep="/"))
  setnames(dt2, cols)
  setkey(dt, contig_name)

  # take top hit from each
  bestleft <- group_by(dt, contig_name) %>% top_n(n=1, wt=bitscore)
  bestright <- group_by(dt2, contig_name) %>% top_n(n=1, wt=bitscore)
  setnames(bestright, 1:2, c("target", "contig_name"))

  # merge
  ungroup(bestleft)
  ungroup(bestright)
  setkey(bestleft, contig_name, target)
  setkey(bestright, contig_name, target)

  merged <- (
    merge(bestleft, bestright) %>%
    select(target:tlen.x)
  )

  setnames(merged, c("target", "contig_name", cols[3:length(cols)]))
  setcolorder(merged, c("contig_name", "target", cols[3:length(cols)]))

  return(merged)
}

load_data_rbb <- function(blast, transrate, rsem,
                          species, assem, keepall=FALSE) {

  library(dplyr)

  dt <- load_rbbs(blast)

  dt[, precision:=id * alnlen / qlen / 100]
  dt[, recall:=id * alnlen / tlen / 100]
  dt[, accuracy:=2 * (precision * recall) / (precision + recall)]

  dt <- group_by(dt, contig_name) %>%
    top_n(n=1, wt=accuracy) %>%
    do(head(., 1))

  dt_ts <- fread(paste(data_dir, transrate, sep="/"))
  setkey(dt_ts, contig_name)

  dt <- merge(as.data.frame(dt_ts[,c('contig_name', 'score', 'length', 'p_good',
                                     'p_bases_covered', 'p_seq_true',
                                     'p_not_segmented', 'eff_length',
                                     'eff_count', 'tpm'),
                                  with=FALSE]),
              as.data.frame(dt[, c('contig_name', 'target', 'id', 'evalue',
                                   'bitscore', 'precision', 'recall',
                                   'accuracy'),
                               with=FALSE]),
              all.x=keepall)
  dt <- as.data.table(dt)
  setkey(dt, contig_name)

  dt[, sp:=species]
  dt[, assembler:=assem]
  dt[, score:=as.numeric(score)]
  dt[is.na(accuracy), accuracy:=0]

  if (!is.null(rsem) && nchar(rsem) > 0) {
    rsemdt <- fread(paste(data_dir, rsem, sep="/"))
    setnames(rsemdt, c('contig_name', names(rsemdt)[2:length(names(rsemdt))]))
    setkey(rsemdt, contig_name)
    dt <- merge(dt, rsemdt[,c('contig_name', 'contig_impact_score'), with=F])
  } else {
    dt[, contig_impact_score := 0]
  }

  return(dt)
}

# LOAD METADATA
meta <- fread('../data/metadata.csv')

# SIMULATED DATA
sim_meta <- subset(meta, datatype=="simulated")
sim_data_rbb <- data.table()
sim_cor <- data.table()

do_cor <- function(dt, species, assembler) {
  dt_local <- dt[, c('score', 'contig_impact_score', 'accuracy'), with=F]
  setnames(dt_local, c('transrate', 'rsem_eval', 'reference'))
  res <- cor(dt_local, method="spearman")
  return(data.table(species, assembler, cor=res))
}

for (i in 1:nrow(sim_meta)) {
  row <- sim_meta[i, ]
  dt_rbb <- load_data_rbb(row[['blast']], row[['transrate']], row[['rsem']],
                  row[['species']], row[['assembler']], keepall=TRUE)
  sim_data_rbb <- rbind(sim_data_rbb, dt_rbb)
  dt_cor <- do_cor(dt_rbb, row[['species']], row[['assembler']])
  sim_cor <- rbind(sim_cor, dt_cor)
}
