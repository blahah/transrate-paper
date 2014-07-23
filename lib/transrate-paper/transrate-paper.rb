#!/usr/bin/env ruby

require 'bindeps'
require 'json'
require 'open3'

module Transrate_Paper

  class Transrate_Paper

    def initialize
    end

    def install_dependencies
      puts "Checking dependencies"
      gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
      gem_deps = File.join(gem_dir, 'deps', 'deps.yaml')
      Bindeps.require gem_deps
    end

    def download_data
      json_str = File.open("source.json").readlines("").first
      hash = JSON.parse(json_str)
      if !Dir.exist?("data")
        Open3.capture3 "mkdir data"
      end
      puts "Downloading data from SRA..."
      hash.each do |key, list|
        list.each do |file|
          if !File.exist?("data/#{file}")
            cmd = "wget #{file} -P data"
            puts cmd
            stdout, stderr, status = Open3.capture3 cmd
            if !status.success?
              raise RuntimeError.new("Downloading #{file} from the SRA failed")
            end
            cmd = "fastq-dump.2.3.5.2 #{file}"
            stdout, stderr, status = Open3.capture3 cmd
            if !status.success?
              raise RuntimeError.new("Couldn't extract fastq from sra #{file}")
            end
          end
        end
      end
      puts "Done"
    end
  end
end