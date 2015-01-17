#!/usr/bin/env ruby

require 'bindeps'
require 'json'
require 'yaml'
require 'open3'
require 'which'
include Which

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
    end

    def download_data yaml
      @data = YAML.load_file yaml
      if !Dir.exist?(File.join(@gem_dir, "data"))
        Dir.mkdir(File.join(@gem_dir, "data"))
      end
      puts "Downloading and extracting data..."
      @data.each do |experiment_name, experiment_data|
        if !Dir.exist?(File.join(@gem_dir, "data", experiment_name.to_s))
          Dir.mkdir(File.join(@gem_dir, "data", experiment_name.to_s))
        end
        experiment_data.each do |key, value|
          output_dir = File.join(@gem_dir, "data",
                                 experiment_name.to_s, key.to_s)
          if [:reads, :assembly, :reference].include? key
            value.each do |description, paths|
              if description == :url
                paths.each do |url|
                  # create output directory
                  if !Dir.exist?(output_dir)
                    Dir.mkdir(output_dir)
                  end
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
        if !Dir.exist?(File.join(@gem_dir, "data", experiment_name.to_s,
                                 "transrate"))
          Dir.mkdir(File.join(@gem_dir, "data", experiment_name.to_s,
                              "transrate"))
        end
        experiment_data[:assembly][:fa].each do |assembler, path|
          output_dir = File.join(@gem_dir, "data", experiment_name.to_s,
                                 "transrate", assembler.to_s)
          assembly_path = File.expand_path(File.join(@gem_dir, "data",
                                      experiment_name.to_s, "assembly", path))
          if !Dir.exist?(output_dir)
            Dir.mkdir(output_dir)
          end
          Dir.chdir(output_dir) do |dir|
            puts "changed to #{dir}"
            experiment_data[:reference][:fa].each do |reference|
              reference_path = File.expand_path(File.join(@gem_dir, "data",
                                experiment_name.to_s, "reference", reference))
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
              cmd << " --reference #{reference_path}"
              cmd << " --threads #{threads}"
              cmd << " --outfile #{assembler}-#{reference}"

              puts cmd
              if !File.exist?("#{assembler}-#{reference}_assemblies.csv")
                stdout, stderr, status = Open3.capture3 cmd
                File.open("log-#{assembler.to_s}-#{reference}.txt","wb") do |out|
                  out.write(stdout)
                  out.write(stderr)
                end
              end
            end
          end
        end
      end
    end

    def transonerate threads
      @data.each do |experiment_name, experiment_data|
        if !Dir.exist?(File.join(@gem_dir, "data", experiment_name.to_s,
                                 "transonerate"))
          Dir.mkdir(File.join(@gem_dir, "data", experiment_name.to_s,
                              "transonerate"))
        end
        genome = experiment_data[:genome][:fa].first
        genome_path = File.expand_path(File.join(@gem_dir, "data",
                                      experiment_name.to_s, "genome", genome))
        gtf = experiment_data[:annotation][:gtf].first
        gtf_path = File.expand_path(File.join(@gem_dir, "data",
                                     experiment_name.to_s, "annotation", gtf))
        output_dir = File.join(@gem_dir, "data", experiment_name.to_s,
                                 "transonerate")
        assemblers = []
        experiment_data[:assembly][:fa].each do |assembler, path|
          assembly_path = File.expand_path(File.join(@gem_dir, "data",
                                      experiment_name.to_s, "assembly", path))
          assemblers << assembly_path
        end

        if !Dir.exist?(output_dir)
          Dir.mkdir(output_dir)
        end
        puts "changing to #{output_dir}"
        Dir.chdir(output_dir) do
          cmd = "transonerate "
          cmd << " --assembly #{assemblers.join(",")}"
          cmd << " --genome #{genome_path}"
          cmd << " --gtf #{gtf_path}"

          left = []
          experiment_data[:reads][:left].each do |fastq|
            left << File.expand_path(File.join(@gem_dir, "data",
                                   experiment_name.to_s, "reads", fastq))
          end
          cmd << " --left "
          cmd << left.join(",")

          right = []
          experiment_data[:reads][:right].each do |fastq|
            right << File.expand_path(File.join(@gem_dir, "data",
                                   experiment_name.to_s, "reads", fastq))
          end
          cmd << " --right "
          cmd << right.join(",")

          cmd << " --output transonerate.out" # output is a suffix
          cmd << " --threads #{threads}"

          puts cmd
          stdout, stderr, status = Open3.capture3 cmd
          if !status.success?
            puts stdout
            puts stderr
            abort "something went wrong with transonerate"
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
        cmd = "fastq-dump.2.3.5.2 --origfmt --split-3 #{name} --outdir #{output_dir}"
        puts cmd
        stdout, stderr, status = Open3.capture3 cmd
      end
    end

  end
end
