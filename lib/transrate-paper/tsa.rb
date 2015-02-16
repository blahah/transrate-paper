module TransratePaper

  require 'fileutils'
  require 'fixwhich'
  require 'yaml'

  class Tsa

    # tsa.XXXX.##.gbff.gz     RNA GenBank flatfiles
    # tsa.XXXX.##.fsa_nt.gz   RNA FASTA files

    # tsa.XXXX.##.gnp.gz      Protein GenPept flatfiles
    # tsa.XXXX.##.fsa_aa.gz   Protein FASTA files

    # tsa.XXXX.mstr.gbff.gz   TSA master-record GenBank flatfile
    # stats.tsa.XXXX          Summary TSA statistics

    def initialize
      @ftp = "ftp://ftp.ncbi.nih.gov/genbank/tsa/"
      @sra_sam = "ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR133/SRR1336770/SRR1336770.sra"
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
      @list = "#{@gem_dir}/tsa_list.txt"
      @data = {}
      @results = {}
      @fastq_dump = which('fastq-dump').first
    end

    def run_transrate threads
      FileUtils.mkdir_p("#{@gem_dir}/data/genbank")
      Dir.chdir("#{@gem_dir}/data/genbank") do
        File.open(@list).each_line do |line|
          cols = line.chomp.split("\t")
          tsa = cols[0]
          sra = cols[1].split(",")
          transcripts = cols[2]
          tool = cols[3]
          phylogeny = cols[4]
          if tsa =~ /tsa.([A-Z]{4}).mstr.gbff/
            code = $1
          end
          if sra.length == 1
            download_tsa_assembly(code)
            result = download_tsa_sra(code, sra.first)
            if result
              Dir.chdir("#{@gem_dir}/data/genbank/#{code}") do |dir|
                # run fastqc first
                files = ["#{code}_1.fastq", "#{code}_2.fastq"]
                run_fastqc files
                #
                cmd = "transrate --assembly #{code}.fa"
                cmd << " --left #{files.first}"
                cmd << " --right #{files.last}"
                cmd << " --threads #{threads}"
                cmd << " --outfile #{code}"
                puts cmd
                if !File.exist?("#{code}_assemblies.csv")
                  stdout, stderr, status = Open3.capture3 cmd
                  if !status.success?
                    abort "ERROR: transrate : #{code}\n#{stdout}\n#{stderr}"
                  end
                  log = "#{code}-transrate.out"
                  File.open(log, "wb") { |io| io.write stdout }
                end
                read_length = get_read_length(files.first)
                score = optimal = 0
                File.open(log).each_line do |line|
                  if line =~ /TRANSRATE ASSEMBLY SCORE:\s+([0-9.]+)/
                    score = $1.to_f
                  end
                  if line =~ /OPTIMAL SCORE:\s+([0-9.]+)/
                    optimal = $1.to_f
                  end
                end
                @results[code] = { :score => score,
                                   :optimal => optimal,
                                   :read_length => read_length,
                                   :tool => tool,
                                   :phylogeny => phylogeny }
              end
            end
          end
        end
      end
      File.open("tsa-results.txt", "wb") do |io|
        @results.each do |code, hash|
          hash = {:code => code}.merge(hash)
          io.write hash.values.join("\t")
        end
      end
    end

    def run_fastqc files
      fastqc = Fastqc.new
      fastqc.run files
      files.each do |file|
        fastqc.analyse_output
        File.open("fastqc-#{file}.yml", "wb") do |file|
          file.write fastqc.data.to_yaml
        end
      end
    end

    def download_tsa_assembly code # ie GAAA
      FileUtils.mkdir_p("#{@gem_dir}/data/genbank/#{code}")
      Dir.chdir("#{@gem_dir}/data/genbank/#{code}") do
        if !File.exist?("#{code}.fa")
          dest = "#{code}.fa.gz"
          dl_assembly = "wget #{@ftp}tsa.#{code}.1.fsa_nt.gz -O #{dest}"
          puts dl_assembly
          stdout, stderr, status = Open3.capture3 dl_assembly
          if !status.success?
            puts "couldn't download #{code} assembly"
            return false
          end
          if File.exist?(dest)
            uncompress = "gunzip #{dest}"
            puts uncompress
            stdout, stderr, status = Open3.capture3 uncompress
            if !status.success?
              puts "something went wrong with gunzipping #{dest}"
              return false
            end
          else
            puts "couldn't find #{dest}"
            return false
          end
        end
      end
      return true
    end

    def download_tsa_sra code, sra
      FileUtils.mkdir_p("#{@gem_dir}/data/genbank/#{code}")
      Dir.chdir("#{@gem_dir}/data/genbank/#{code}") do
        dest = "#{code}.sra"
        if File.exist?("#{code}_1.fastq")
          # fastq already exists
          return true
        elsif File.exist?("#{code}.fastq")
          # sra extracted to non paired fastq file
          return false
        else
          if File.exist?("#{code}.sra")
            # sra already exists
          else
            # download sra
            url = "ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/"
            url << "sra/SRR/#{sra[0..5]}/#{sra}/#{sra}.sra"
            dl_sra = "wget #{url} -O #{dest}"
            puts dl_sra
            stdout, stderr, status = Open3.capture3 dl_sra
            if !status.success?
              puts "couldn't download #{code} sra"
              return false
            end
          end
          dump = "#{@fastq_dump} --origfmt --split-3 #{dest}"
          puts dump
          stdout, stderr, status = Open3.capture3 dump
          if !status.success?
            puts "something went wrong with fastq-dump of #{dest}"
            return false
          end
          File.delete(dest)
          if File.exist?("#{code}.fastq")
            # sra extracted to non paired fastq file
            return false
          end
        end
      end
      return true
    end

    ## the code below this line isn't used, but was used initially to generate
    ## the list of tsa genbank files

    # list is a file containing a single column of identifiers
    # file in test/data/test_list_full.txt
    # eg tsa.GAFD.mstr.gbff.gz

    def download_genbank list
      @genbank=[]
      File.open(list).each_line do |line|
        @genbank << line.chomp
      end
      FileUtils.mkdir_p("#{@gem_dir}/data/genbank")
      @genbank.each do |link|
        dl = "#{@ftp}#{link}.gz"
        # puts "downloading this file: #{dl}"

        Dir.chdir("#{@gem_dir}/data") do
          Dir.chdir("genbank") do
            if !File.exist?("#{link}")
              wget = "wget #{@ftp}#{link}.gz -O #{link}.gz"
              puts wget
              `#{wget}`
              gunzip = "gunzip #{link}.gz"
              puts gunzip
              `#{gunzip}`
            else
              # puts "#{link} already exists"
            end
          end
        end
      end
    end

    # generate list of tsa entries for analysis
    # select entries that have at least 5000 contigs
    # and contain a paired reads in a sra link
    # should have only a small size of sra files (1 lib, < 8GB)
    def download_data
      Dir.chdir("#{@gem_dir}/data/genbank") do
        @genbank.each do |gb|
          # puts "genbank parsing file: #{gb}"
          parse_genbank gb
        end
      end
      File.open("tsa_list_sra_long.txt", "w") do |io|
        @data.each do |key, hash|
          if hash[:contigs] >= 5000
            if hash[:assembly_method]
              if hash[:sra] and hash[:sra].size>0 # maybe make this: size==1
                if check_paired(hash[:sra].first)
                  out = ""
                  out << "#{key}\t"
                  out << "#{hash[:sra].join(",")}\t"
                  out << "#{hash[:contigs]}\t"
                  out << "#{hash[:assembly_method]}\t"
                  out << "#{hash[:organism]}\n"
                  io.write "#{out}"
                end
              end
            end
          end
        end
      end
    end

    def parse_genbank genbank
      header=nil
      subheader=nil
      subsubheader=nil
      hash={}
      # puts "genbank: #{genbank}"
      File.open(genbank).each_line do |line|
        if line=~/^([A-Z]+)\ +(\S.*)/
          header = $1
          subheader = nil
          subsubheader = nil
          info = $2
          hash[header] ||= {}
          info = parse_header(header, info)
          if info.is_a?(Hash)
            info.each do |key, value|
              hash[header][key]=value
            end
          else
            hash[header][header] = info
          end
        elsif line=~/^\ \ ([A-Z]+)\ +(\S.*)/
          subheader = $1
          info = $2
          info = parse_header(header, info)
          hash[header][subheader] = info
        elsif line=~/\ +(\S.*)/
          info = $1
          info = parse_header(header, info)
          if subheader
            hash[header][subheader] << info
          else
            if info.is_a?(Hash)
              # puts "info:"
              # p info
              info.each do |key, value|
                if key=="Sequence Read Archive" or key=="BioSample"
                  subsubheader = key
                end
                hash[header][key]=value
              end
            else
              if subsubheader
                hash[header][subsubheader] << info
              else
                # puts "header: #{header}\tinfo:#{info}"
                hash[header][header] << info
              end
            end
          end
        end
      end
      key = File.basename(genbank)
      @data[key] = {}
      @data[key][:assembly_method] = hash['COMMENT']['Assembly Method']
      @data[key][:contigs] = hash['REFERENCE']['CONTIGS']
      @data[key][:organism] = hash['SOURCE']['ORGANISM']
      if hash['DBLINK']['Sequence Read Archive']
        @data[key][:sra] = []
        hash['DBLINK']['Sequence Read Archive'].split(",").each do |sra|
          @data[key][:sra] << sra.strip
        end
      elsif hash['DBLINK']['BioSample']
        @data[key][:sra] = []
        hash['DBLINK']['BioSample'].split(",").each do |sra|
          @data[key][:sra] << sra.strip
        end
      end
    end

    def parse_header(header, info)
      if header=='DBLINK'
        desc, data = info.split(":")
        if data
          info = {}
          info[desc.strip]=data.strip
        end
      elsif header=='COMMENT'
        if info=~/Assembly\ Method/
          key, value = info.split("::")
          info = {}
          info[key.strip] = value.strip
        end
      elsif header=='REFERENCE'
        if info=~/bases\ [0-9]+\ to\ ([0-9]+)/
          info = {}
          info["CONTIGS"] = $1.to_i
        end
      elsif header=='SOURCE'
        if info !~ /;/
          info << "; "
        end
      end
      return info
    end

    def check_paired sra
      #http://www.ncbi.nlm.nih.gov/sra/?term=SRR547977
      puts "checking sra: #{sra}"
      cmd = "curl http://www.ncbi.nlm.nih.gov/sra/?term=#{sra}"
      paired = false
      size = 0
      stdout, stderr, status = Open3.capture3 cmd
      if status.success?
        if stdout =~ /PAIRED/
          paired = true
        elsif stdout =~ /SINGLE/
          paired = false
        else
          paired = false
        end
      else
        puts stdout
        puts stderr
        puts "something went wrong with curl #{sra}"
      end
      sleep 1
      return paired
    end

    def get_read_length(left)
      count=0
      file = File.open(left.split(",").first)
      name = file.readline.chomp
      seq = file.readline.chomp
      na = file.readline.chomp
      qual = file.readline.chomp
      read_length = 0
      while name and count < 5000 # get max read length from first 5000 reads
        read_length = [read_length, seq.length].max
        name = file.readline.chomp rescue nil
        seq = file.readline.chomp rescue nil
        na = file.readline.chomp rescue nil
        qual = file.readline.chomp rescue nil
        count+=1
      end
      read_length
    end

  end
end
