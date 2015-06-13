# sync data from a remote machine to this one
# usage: sync_data.sh remote_host:/path/to/transrate-paper
ARGV=("$@")
ARGC=("$#")

if [ $ARGC -ne 1 ]; then
  printf "\nusage: sync_data.sh remote_host:/path/to/transrate-paper\n\n"
  exit
fi;

# yeast

scp $1/data/yeast/transrate/oases/*.csv ./data/yeast/transrate/oases/
scp $1/data/yeast/transrate/trinity/*.csv ./data/yeast/transrate/trinity/

scp $1/data/mouse/rsem-eval/oases/rsem_eval.score.isoforms.results  ./data/yeast/rsem_eval/oases/
scp $1/data/mouse/rsem-eval/trinity/rsem_eval.score.isoforms.results  ./data/yeast/rsem_eval/trinity/

# human

scp $1/data/human/transrate/oases/*.csv ./data/human/transrate/oases/
scp $1/data/human/transrate/trinity/*.csv ./data/human/transrate/trinity/

scp $1/data/human/rsem-eval/oases/rsem_eval.score.isoforms.results ./data/human/rsem_eval/oases/
scp $1/data/human/rsem-eval/trinity/rsem_eval.score.isoforms.results ./data/human/rsem_eval/trinity/


# rice

scp $1/data/rice/transrate/oases/*.csv ./data/rice/transrate/oases/
scp $1/data/rice/transrate/trinity/*.csv ./data/rice/transrate/trinity/
scp $1/data/rice/transrate/soapdenovotrans/*.csv ./data/rice/transrate/soapdenovotrans/

scp $1/data/rice/rsem-eval/oases/rsem_eval.score.isoforms.results ./data/rice/rsem_eval/oases/
scp $1/data/rice/rsem-eval/trinity/rsem_eval.score.isoforms.results ./data/rice/rsem_eval/trinity/
scp $1/data/rice/rsem-eval/soapdenovotrans/rsem_eval.score.isoforms.results ./data/rice/rsem_eval/soapdenovotrans/

# mouse

scp $1/data/mouse/transrate/oases/*.csv ./data/mouse/transrate/oases/
scp $1/data/mouse/transrate/trinity/*.csv ./data/mouse/transrate/trinity/
scp $1/data/mouse/transrate/soapdenovotrans/*.csv ./data/mouse/transrate/soapdenovotrans/

scp $1/data/mouse/rsem-eval/oases/rsem_eval.score.isoforms.results ./data/mouse/rsem_eval/oases/
scp $1/data/mouse/rsem-eval/trinity/rsem_eval.score.isoforms.results ./data/mouse/rsem_eval/trinity/
scp $1/data/mouse/rsem-eval/soapdenovotrans/rsem_eval.score.isoforms.results ./data/mouse/rsem_eval/soapdenovotrans/
