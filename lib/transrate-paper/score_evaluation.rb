#!/usr/bin/env ruby

require 'bindeps'
require 'json'
require 'yaml'
require 'open3'
require 'which'
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

    def run threads
      @threads = threads
      # simulation
      ### download rice reference transcriptome (us local for the moment)
      transcriptome = File.join(@gem_dir, "rice_reference.fa")
      ### simulation_accuracy
      score = simulation_accuracy transcriptome
    end

    # Align assembly to genome with BLAT and evaluate the proportion of
    # contigs in each transrate score decile that are perfectly represented
    # in the genome
    def genome_accuracy(assembly, genome, scores)

    end

    # Align assembly to reference transcriptome with BLAT. Considering
    # only the contigs that align to a reference transcript, evaluate
    # the correlation of contig score with how well the contig reconstructs
    # the reference transcript it aligns to.
    def transcriptome_accuracy(assembly, transcriptome, scores)

    end

    # Simulate reads from a reference transcriptome such that the reads
    # perfectly agree with the reference. Transrate run with these reads
    # should give a near-perfect score.
    def simulation_accuracy transcriptome
      # simulate reads
      out_dir = File.join(@gem_dir,"data","simulation",transcriptome)
      make_dir out_dir
      Dir.chdir(out_dir) do |dir|
        simulator = Simulator.new transcriptome, 5, 100, 250, 50
        prefix = "#{File.basename(transcriptome)}_sim"
        simulator.simulate prefix
        # run transrate with reads against transcriptome
        cmd = "transrate --assembly #{transcriptome}"
        cmd << " --left  #{prefix}_1.fastq"
        cmd << " --right #{prefix}_2.fastq"
        cmd << " --outfile #{prefix}"
        cmd << " --threads #{@threads}"
        stdout, stderr, status = Open3.capture3(cmd)
        # return score
      end
    end

    def make_dir dir
      if Dir.exist?(dir) or dir==""
      else
        dirname = File.dirname(dir)
        make_dir dirname
        Dir.mkdir(dir)
      end
    end

  end

end
