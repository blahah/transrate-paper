## transrate figures - load data


species_list <- as.factor(c('mouse', 'rice', 'human', 'yeast'))
assemblers <- c('trinity', 'oases', 'soap')
datasets <- expand.grid(species_list, assemblers)
datasets <- apply(datasets, MARGIN = 2, FUN = as.character)

score_cols <- c('p_good', 'p_not_segmented', 'p_bases_covered',
                'p_seq_true', 'score',
                'length', 'coverage')
library(data.table)
wide_data <- data.table()
library(reshape2)
library(dplyr)

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
}
wide_data[assembler == 'soapdenovotrans', assembler:='soap']
wide_data[, species:=factor(species, levels=species_list)]
wide_data[, assembler:=factor(assembler, levels=assemblers)]
wide_data <- group_by(wide_data, assembler, species)
data <- melt(wide_data, id.vars = c('species', 'assembler', 'score',
                                    'length', 'coverage'),
             variable.name = 'score_component')
