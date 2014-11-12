#!/usr/bin/env ruby

require 'bindeps'
require 'json'
require 'yaml'
require 'open3'
require 'which'
include Which

module TransratePaper

  # The ScoreEvaluation class uses ground-truth datasets and simulation to
  # evaluate the accuracy of the transrate contig score
  class ScoreEvaluation

    def initialize yaml
      @yaml = yaml # description and location of the data
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
    end

    def install_dependencies

    end

    def run threads
      @threads = threads
      # simulation
      ### download rice reference transcriptome (use local for the moment)
      data = YAML.load_file @yaml
      download_transcriptomes(data)
      data.each do |experiment_name, experiment_data|
        puts experiment_name
        transcriptome = File.join(@gem_dir, "data", experiment_name.to_s,
          "transcriptome", experiment_data[:transcriptome][:fa])
        puts transcriptome
        score = simulation_accuracy(experiment_name.to_s, transcriptome)
        puts score
      end

    end

    def download_transcriptomes data
      puts "Downloading transcriptomes..."
      dir = File.join(@gem_dir, "data")
      Dir.mkdir(dir) if !Dir.exist?(dir)
      data.each do |experiment_name, experiment_data|
        edir = "#{dir}/#{experiment_name.to_s}"
        Dir.mkdir(edir) if !Dir.exist?(edir)
        tdir = "#{edir}/transcriptome"
        Dir.mkdir(tdir) if !Dir.exist?(tdir)
        url = experiment_data[:transcriptome][:url]
        dest = File.join(tdir, File.basename(url))
        fa = File.join(tdir, experiment_data[:transcriptome][:fa])
        if !File.exist?(dest) and !File.exist?(fa)
          cmd = "wget #{url} -O #{dest}"
          puts cmd
          stdout, stderr, status = Open3.capture3(cmd)
          if !status.success?
            puts "something went wrong with the download of: #{url}"
          end
        else
          puts "#{dest} already exists"
        end
        if File.exist?(dest) and !File.exist?(fa)
          cmd = "gunzip #{dest}"
          puts cmd
          stdout, stderr, status = Open3.capture3(cmd)
        end
      end
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
    def simulation_accuracy name, transcriptome
      # simulate reads
      out_dir = File.join(@gem_dir, "data", name, "simulation")
      make_dir out_dir
      score = 0
      Dir.chdir(out_dir) do |dir|
        simulator = Simulator.new transcriptome, 100, 250, 50
        prefix = "#{File.basename(transcriptome)}_sim"
        left, right = simulator.simulate prefix
        # run transrate with reads against transcriptome
        cmd = "transrate --assembly #{transcriptome}"
        cmd << " --left #{left}"
        cmd << " --right #{right}"
        cmd << " --outfile #{prefix}"
        cmd << " --threads #{@threads}"
        stdout, stderr, status = Open3.capture3(cmd)
        if stdout =~ /TRANSRATE.ASSEMBLY.SCORE:.([0-9\.]+)/
          score = $1
          File.open("#{prefix}.out", "w") { |io| io.write(stdout) }
        end
      end
      score
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
