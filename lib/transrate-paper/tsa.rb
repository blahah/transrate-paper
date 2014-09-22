module TransratePaper

  class Tsa

    def initialize
      @ftp = "ftp://ftp.ncbi.nih.gov/genbank/tsa/"
      @list = "tsa_list.txt"
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
      @data = {}
    end

    def run_transrate threads
      #cmd = "fastq-dump.2.3.5.2 --origfmt --split-3 #{name} --outdir #{output_dir}"
    end

    def download_genbank list
      @genbank=[]
      File.open(list).each_line do |line|
        @genbank << line.chomp
      end
      @genbank.each do |link|
        dl = "#{@ftp}#{link}.gz"
        # puts "downloading this file: #{dl}"
        if !Dir.exist?("#{@gem_dir}/data")
          Dir.mkdir("#{@gem_dir}/data")
        end
        Dir.chdir("#{@gem_dir}/data") do
          if !Dir.exist?("#{@gem_dir}/data/genbank")
            Dir.mkdir("#{@gem_dir}/data/genbank")
          end
          Dir.chdir("genbank") do
            if !File.exist?("#{link}")
              curl = "curl #{@ftp}#{link}.gz -o #{link}.gz"
              puts curl
              `#{curl}`
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
    def download_data
      Dir.chdir("#{@gem_dir}/data/genbank") do
        @genbank.each do |gb|
          # puts "genbank parsing file: #{gb}"
          parse_genbank gb
        end
      end
      File.open("tsa_list.txt", "w") do |io|
        @data.each do |key, hash|
          if hash[:contigs] >= 5000
            if hash[:assembly_method]
              if hash[:sra] and hash[:sra].size>0
                if check_paired(hash[:sra].first)
                  out = ""
                  out << "#{key}\t"
                  out << "#{hash[:sra].first}\t"
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
        puts "something went wrong with curling #{sra}"
      end
      sleep 1
      return paired
    end

  end
end