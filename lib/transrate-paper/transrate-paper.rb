#!/usr/bin/env ruby

require 'bindeps'
require 'json'
require 'yaml'
require 'open3'

module Transrate_Paper

  class Transrate_Paper

    def initialize
      @data = {} # description and location of the data
    end

    def install_dependencies
      puts "Checking dependencies"
      gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
      gem_deps = File.join(gem_dir, 'deps', 'deps.yaml')
      Bindeps.require gem_deps
    end

    def download_data
      @data = YAML.load_file "data.yaml"
      Dir.mkdir("data")
      puts "Downloading and extracting data..."
      @data.each do |experiment_name, experiment_data|
        Dir.mkdir(File.join("data", experiment_name.to_s))
        experiment_data.each do |key, value|
          output_dir = File.join("data", experiment_name.to_s, key.to_s)
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
                    curl(url, name)
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

    def run_transrate
      @data.each do |experiment_name, experiment_data|
        experiment_data[:assembly][:fa].each do |assembler, path|
          output_dir = File.join("data", experiment_name.to_s,
                                 "transrate", assembler.to_s)
          assembly_path = File.expand_path(File.join("data",
                                      experiment_name.to_s, "assembly", path))
          if !Dir.exist?(output_dir)
            Dir.mkdir(output_dir)
          end
          Dir.chdir(output_dir) do |dir|
            puts "changed to #{dir}"

            cmd = "transrate "
            cmd << " --assembly #{assembly_path} "
            cmd << " --left "
            left = []
            experiment_data[:reads][:left].each do |fastq|
              left << fastq
            end
            cmd << left.join(",")
            cmd << " --right "
            right = []
            experiment_data[:reads][:right].each do |fastq|
              right << fastq
            end
            cmd << right.join(",")
            cmd << " --reference "
            refs = []
            experiment_data[:reference][:fa].each do |reference|
              refs << reference
            end
            cmd << refs.join(",")
            cmd << " --outfile #{assembler}"

            puts cmd
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

    def curl(url, name)
      cmd = "curl #{url} -o #{name}"
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