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
      puts "Downloading and extracting data..."
      @data.each do |experiment_name, experiment_data|
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
                  # download file
                  name = File.join(output_dir, File.basename(url))
                  if !File.exist?(name)
                    cmd = "curl #{url} -o #{name}"
                    puts cmd
                    stdout, stderr, status = Open3.capture3 cmd
                  else
                    puts "#{name} already exists"
                  end
                  # uncompress file
                  if name =~ /\.tar\.gz$/
                    cmd = "tar xzf #{name} -C data"
                    puts cmd
                    `#{cmd}`
                    if !Dir.exist?(name.gsub(".tar.gz", ""))
                      raise RuntimeError.new("Unpacking #{file} failed")
                    end
                  elsif name =~ /\.gz$/
                    cmd = "gunzip #{name}"
                    puts cmd
                    `#{cmd}`
                  elsif name =~ /\.sra$/

                  end
                end
              end
            end
          end
        end
      end
      puts "Done"
    end

  end
end