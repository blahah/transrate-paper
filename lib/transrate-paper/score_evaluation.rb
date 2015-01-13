#!/usr/bin/env ruby

require 'bindeps'
require 'json'
require 'yaml'
require 'open3'
require 'fixwhich'
require 'crb-blast'

module TransratePaper

  # The ScoreEvaluation class uses ground-truth datasets and simulation to
  # evaluate the accuracy of the transrate contig score
  class ScoreEvaluation

    def initialize
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
      @threads = 8
    end

    def install_dependencies

    end

    def run yaml, threads=8
      @threads = threads
      # simulation
      ### download rice reference transcriptome (use local for the moment)
      data = YAML.load_file yaml
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

    # Simulate reads from a reference transcriptome
    # Assemble reads with trinity, soap, oases
    # Transrate the assembly
    # crb-blast the contigs to the reference
    def assembly_accuracy(name, transcriptome)
      out_dir = File.join(@gem_dir, "data", name, "assembly_simulation")
      make_dir out_dir
      Dir.chdir(out_dir) do |dir|
        puts "changing to #{out_dir}"
        simulator = Simulator.new transcriptome, 100, 250, 50
        prefix = "#{File.basename(transcriptome)}_sim"
        left, right = simulator.simulate prefix
        left = File.expand_path(left)
        right = File.expand_path(right)
        puts "simulated reads:\n#{left}\n#{right}"

        make_dir "#{out_dir}/soap"
        Dir.chdir("#{out_dir}/soap") do |dir|
          contigs = soap(left, right)
          # run transrate with the reads against the contigs
          score = run_transrate(left, right, transcriptome, prefix)
          # crb-blast the soap contigs against the transcriptome reference
          crb = CRB_Blast::CRB_Blast.new(contigs, transcriptome)
          crb.run
          crb.write_output
        end

      end
    end

    def soap(left, right)
      config = "max_rd_len=5000\n"
      config << "[LIB]\n"
      config << "avg_ins=\n"
      config << "reverse_seq=0\n"
      config << "asm_flags=3\n"
      config << "q1=#{left}\n"
      config << "q2=#{right}\n"
      File.open("sdt.config", "w") { |io| io.write config }
      cmd = "SOAPdenovo-Trans-127mer all"
      cmd << " -s sdt.config"
      cmd << " -o output"
      cmd << " -K 37"
      cmd << " -d 1"
      # cmd << " -S -F"
      puts cmd
      puts "starting soap assembly"
      stdout, stderr, status = Open3.capture3(cmd)
      return "output.contig"
    end

    def trinity(left, right)

    end

    def oases(left, right)

    end

    # Simulate reads from a reference transcriptome such that the reads
    # perfectly agree with the reference. Transrate run with these reads
    # should give a near-perfect score.
    def simulation_accuracy(name, transcriptome)
      # simulate reads
      out_dir = File.join(@gem_dir, "data", name, "simulation")
      make_dir out_dir
      score = 0
      Dir.chdir(out_dir) do |dir|
        simulator = Simulator.new transcriptome, 100, 250, 50
        prefix = "#{File.basename(transcriptome)}_sim"
        left, right = simulator.simulate prefix
        # run transrate with reads against transcriptome
        score = run_transrate left, right, transcriptome, prefix
      end
      score
    end

    def run_transrate(left, right, reference, prefix)
      score = 0
      cmd = "transrate --assembly #{reference}"
      cmd << " --left #{left}"
      cmd << " --right #{right}"
      cmd << " --outfile #{prefix}"
      cmd << " --threads #{@threads}"
      stdout, stderr, status = Open3.capture3(cmd)
      if status.success?
        if stdout =~ /TRANSRATE.ASSEMBLY.SCORE:.([0-9\.]+)/
          score = $1
          File.open("#{prefix}.transrate", "w") { |io| io.write(stdout) }
        end
      else
        puts "transrate failed"
        File.open("#{prefix}.transrate.failed", "w") do |io|
          io.write("#{stdout}\n#{stderr}")
        end
      end
      return score
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
