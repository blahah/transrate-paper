#!/usr/bin/env ruby

require 'bindeps'
require 'json'
require 'yaml'
require 'open3'
require 'fixwhich'
require 'fileutils'

module TransratePaper

  class TransratePaper

    def initialize
      @data = {} # description and location of the data
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
    end

    def install_dependencies
      puts "Checking dependencies"
      gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
      gem_deps = File.join(gem_dir, 'deps', 'deps.yaml')
      Bindeps.require gem_deps
      @curl = which('curl').first
      @wget = which('wget').first
      if !@curl and !@wget
        msg = "Don't know how to download files without curl or wget installed"
        raise RuntimeError.new(msg)
      end
      #
      @fastq_dump = which('fastq-dump').first
    end

    def download_data yaml
      @data = YAML.load_file yaml
      puts "Downloading and extracting data..."
      @data.each do |experiment_name, experiment_data|
        experiment_data.each do |key, value|
          output_dir = File.join(@gem_dir, "data",
                                 experiment_name.to_s, key.to_s)
          if [:reads, :assembly].include? key
            value.each do |description, paths|
              if description == :url
                paths.each do |url|
                  # create output directory
                  FileUtils.mkdir_p output_dir
                  name = File.join(output_dir, File.basename(url))
                  # download
                  if !already_downloaded name
                    download(url, name)
                  end
                  # extract
                  if !already_extracted name
                    extract(name, output_dir)
                  end

                end
              end
            end
          end
        end
      end
      puts "Done"
    end

    def run_transrate threads
      @data.each do |experiment_name, experiment_data|
        experiment_data[:assembly][:fa].each do |assembler, path|
          output_dir = File.join(@gem_dir, "data", experiment_name.to_s,
                                 "transrate", assembler.to_s)
          assembly_path = File.expand_path(File.join(@gem_dir, "data",
                                      experiment_name.to_s, "assembly", path))
          FileUtils.mkdir_p output_dir
          Dir.chdir(output_dir) do |dir|
            puts "changed to #{dir}"
            cmd = "transrate "
            cmd << " --assembly #{assembly_path} "
            cmd << " --left "
            left = []
            experiment_data[:reads][:left].each do |fastq|
              left << File.expand_path(File.join(@gem_dir, "data",
                                     experiment_name.to_s, "reads", fastq))
            end
            cmd << left.join(",")
            cmd << " --right "
            right = []
            experiment_data[:reads][:right].each do |fastq|
              right << File.expand_path(File.join(@gem_dir, "data",
                                     experiment_name.to_s, "reads", fastq))
            end
            cmd << right.join(",")
            cmd << " --threads #{threads}"
            outfile = "#{experiment_name.to_s}-#{assembler}"
            cmd << " --outfile #{outfile}"

            puts cmd
            if !File.exist?("#{outfile}_assemblies.csv")
              transrate = Cmd.new cmd
              transrate.run
              File.open("log-#{outfile}.txt","wb") do |out|
                out.write(transrate.stdout)
                out.write(transrate.stderr) unless transrate.status.success?
              end
            end
          end
        end
      end
    end

    def run_transrate_merge threads
      @data.each do |experiment_name, experiment_data|
        assemblies = []
        experiment_data[:assembly][:fa].each do |assembler, path|
          output_dir = File.join(@gem_dir, "data", experiment_name.to_s,
                                 "transrate", "merged")
          FileUtils.mkdir_p output_dir
          assembly_path = File.expand_path(File.join(@gem_dir, "data",
                                      experiment_name.to_s, "assembly", path))
          assemblies << assembly_path
        end
        Dir.chdir(output_dir) do |dir|
          puts "changed to #{dir}"
          cmd = "transrate "
          cmd << " --assembly #{assembly_path} "
          cmd << " --left "
          left = []
          experiment_data[:reads][:left].each do |fastq|
            left << File.expand_path(File.join(@gem_dir, "data",
                                   experiment_name.to_s, "reads", fastq))
          end
          cmd << left.join(",")
          cmd << " --right "
          right = []
          experiment_data[:reads][:right].each do |fastq|
            right << File.expand_path(File.join(@gem_dir, "data",
                                   experiment_name.to_s, "reads", fastq))
          end
          cmd << right.join(",")
          cmd << " --threads #{threads}"
          outfile = "#{experiment_name.to_s}"
          cmd << " --outfile #{outfile}"
          cmd << " --merge-assemblies #{experiment_name.to_s}.fasta"
          puts cmd
          if !File.exist?("#{outfile}_assemblies.csv")
            transrate = Cmd.new cmd
            transrate.run
            File.open("log-#{outfile}.txt", "wb") do |out|
              out.write(transrate.stdout)
              out.write(transrate.stderr) unless transrate.status.success?
            end
          end
        end
      end
    end

    def run_rsem_eval threads
      @data.each do |experiment_name, experiment_data|
        experiment_data[:assembly][:fa].each do |assembler, path|
          output_dir = File.join(@gem_dir, "data", experiment_name.to_s,
                                 "rsem-eval", assembler.to_s)
          assembly_path = File.expand_path(File.join(@gem_dir, "data",
                                      experiment_name.to_s, "assembly", path))
          FileUtils.mkdir_p output_dir
          Dir.chdir(output_dir) do |dir|
            puts "changed to #{dir}"
            left = experiment_data[:reads][:left].collect { |fastq|
              File.expand_path(File.join(@gem_dir, "data", experiment_name.to_s, "reads", fastq))
            }.join(",")
            right = experiment_data[:reads][:right].collect { |fastq|
              File.expand_path(File.join(@gem_dir, "data", experiment_name.to_s, "reads", fastq))
            }.join(",")
            cmd = "rsem-eval-calculate-score"
            cmd << " -p #{threads}"
            cmd << " --paired-end #{left} #{right}"
            cmd << " #{assembly_path} rsem_eval 200"

            log = "rsem-eval-#{experiment_name.to_s}-#{assembler.to_s}.log"
            puts cmd
            if !File.exist?(log)
              eval = Cmd.new(cmd)
              eval.run
              File.open(log, "wb") do |io|
                io.write(eval.stdout)
                io.write(eval.stderr) unless eval.status.success?
              end
            end
          end
        end
      end
    end

    def extracted_name name
      if name =~ /\.sra$/
        return File.join(File.dirname(name),
                         "#{File.basename(name, ".sra")}_1.fastq")
      elsif name =~ /\.tar\.gz$/
        return name.gsub(".tar.gz", "")
      elsif name =~ /\.gz$/
        return name.gsub(".gz", "")
      elsif name =~ /\.zip$/
        return name.gsub(".zip", "")
      end
    end

    def already_extracted name
      extracted = extracted_name name
      # puts "extracted_name = #{extracted}"
      if File.exist? extracted
        return true
      elsif Dir.exist? extracted
        return true
      else
        return false
      end
    end

    def already_downloaded name
      extracted = extracted_name name
      # puts "name = #{name}, extracted_name = #{extracted}"
      if File.exist? name
        return true
      elsif File.exist? extracted
        return true
      else
        return false
      end
    end

    def download(url, name)
      if @curl
        cmd = "curl #{url} -o #{name}"
      elsif @wget
        cmd = "wget #{url} -O #{name}"
      else
        raise RuntimeError.new("Neither curl or wget installed")
      end
      puts cmd
      stdout, stderr, status = Open3.capture3 cmd
      if !status.success?
        puts "Download failed\n#{url}\n#{stdout}\n#{stderr}\n"
      end
    end

    def extract(name, output_dir)
      if name =~ /\.tar\.gz$/
        cmd = "tar xzf #{name} -C #{output_dir}"
        puts cmd
        stdout, stderr, status = Open3.capture3 cmd
      elsif name =~ /\.gz$/
        cmd = "gunzip #{name}"
        puts cmd
        stdout, stderr, status = Open3.capture3 cmd
      elsif name =~ /\.zip$/
        cmd = "unzip #{name}"
        puts cmd
        stdout, stderr, status = Open3.capture3 cmd
      elsif name =~ /\.sra$/
        cmd = "#{@fastq_dump} --origfmt --split-3 #{name} --outdir #{output_dir}"
        puts cmd
        stdout, stderr, status = Open3.capture3 cmd
      end
    end

  end
end
