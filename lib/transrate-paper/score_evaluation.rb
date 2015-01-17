require 'bindeps'
require 'json'
require 'yaml'
require 'open3'
require 'which'
require 'crb-blast'
include Which

module Transrate_Paper

  # The ScoreEvaluation class uses ground-truth datasets and simulation to
  # evaluate the accuracy of the transrate contig score
  class ScoreEvaluation

    def initialize data
      @data = data # description and location of the data
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
    end

    def install_dependencies

    end

    def run(threads = 4)
      @threads = threads
    end

    # Assess the quality of each assembly by comparison to the published
    # transcriptome of the same species.
    def run_txome_assessment
      @data.each do |experiment_name, experiment_data|
        datadir = File.join(@gem_dir,
                            "data",
                            experiment_name.to_s,
                            "score_evaluation")
        unless Dir.exist? datadir
          Dir.mkdir datadir
        end
        Dir.chdir datadir do
          experiment_data[:transcriptome][:fa].each do |ref_path|
            learn_expected_bitscores ref_path
            experiment_data[:assembly][:fa].each do |name, assem_path|
              unless Dir.exist? name
                Dir.mkdir name
              end
              Dir.chdir name do
                compare_to_txome(assem_path, ref_path)
              end
            end
          end
        end
      end
    end

    # Find the expected bitscore for each mRNA in a transcriptome, i.e. the
    # bitscore when an mRNA is aligned to itself.
    def learn_expected_bitscores(path)
      blaster = CRB_Blast.new(path, path)
      blaster.run(1e-5, @threads, true)
      bitscores = {}
      blaster.reciprocals.each_pair do |name, hits|
        bitscores[name] = hits.first.bitscore
      end

    end

    # Compare assembled contigs to a reference transcriptome using CRB-Blast
    def compare_to_txome(assem_path, ref_path)
      blaster = CRB_Blast.new(assem_path, ref_path)
      blaster.run(1e-5, @threads, true)
    end

    # Align assembly to genome with BLAT and evaluate the proportion of
    # contigs in each transrate score decile that are perfectly represented
    # in the genome
    def genome_accuracy(assembly, genome, scores)

    end

    # Align assembly to reference transcriptome with BLAST. Considering
    # only the contigs that align to a reference transcript, evaluate
    # the correlation of contig score with how well the contig reconstructs
    # the reference transcript it aligns to.
    def transcriptome_accuracy(assembly, transcriptome, scores)

    end

    # Simulate reads from a reference transcriptome such that the reads
    # perfectly agree with the reference. Transrate run with these reads
    # should give a near-perfect score.
    def simulation_accuracy transcriptome

    end

  end

end
