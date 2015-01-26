module TransratePaper

  class Simulation

    require 'fileutils'
    require 'yaml'
    require 'which'
    include Which

    def initialize
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
      @data = YAML.load_file File.join(@gem_dir, 'data.yaml')
      @wget = which('wget').first
      if !@wget
        msg = "Don't know how to download files without wget installed"
        raise RuntimeError.new(msg)
      end
    end

    # run flux capacitor simulation for each species
    def run
      all_simdata = {}
      @data.each do |name, data|
        if data.has_key? :sim_inputs
          puts "Preparing to simulate reads for #{name.to_s}"
          thissim = data[:sim_inputs]
          # change to experiment dir
          expdir = File.join(@gem_dir, "data", name.to_s)
          datadir = File.join(expdir, 'sim_inputs')
          unless File.exists? datadir
            FileUtils.mkdir_p datadir
          end
          inputs = {}
          # get data
          Dir.chdir datadir do
            inputs[:full] = {
              :genome => File.join(datadir, 'genome/'),
              :annotation => File.join(datadir, thissim[:annotation][:gtf])
            }
            download_inputs thissim
          end
          # create dir for full simulation and run it
          simdir = File.join(expdir, 'simulation')
          Dir.mkdir simdir unless Dir.exist? simdir
          Dir.chdir simdir do
            inputs[:full] = inputs[:full].merge({
              :left => File.expand_path('left.fq'),
              :right => File.expand_path('right.fq')
            })
            puts "Simulating large read set (5 million reads)"
            run_flux(inputs[:full], 10_000_000, 5_000_000)
          end
          # create dir for mini simulation and run it
          tinydir = File.join(expdir, 'tinysim')
          Dir.mkdir tinydir unless Dir.exist? tinydir
          Dir.chdir tinydir do
            inputs[:tiny] = {
              :genome => inputs[:full][:genome],
              :annotation =>  File.join(datadir, 'chr1.gtf'),
              :left => File.expand_path('left.fq'),
              :right => File.expand_path('right.fq')
            }
            puts "Simulating small read set (5 hundred thousand reads) " +
                   "from a single chromosome"
            make_tiny_inputs inputs[:full]
            run_flux(inputs[:tiny], 2_000_000, 500_000)
          end
          all_simdata[name] = inputs
        end
      end
      all_simdata
    end # simulate

    # given a hash of data describing the inputs for a full simulation,
    # extract out a subset of the chromosomes and generate a reference
    # for that
    def make_tiny_inputs inputs
      base = File.dirname(inputs[:annotation])
      chr1 =  File.join(  base, 'chr1.gtf')
      if File.exist? chr1
        puts "chr1.gtf exists, skipping GTF chromosome subsetting"
      else
        puts "Subsetting GTF to get a single chromosome"
        cmd = "cut -f1 #{inputs[:annotation]} | sort | uniq"
        chromosomes = `#{cmd}`
        first = chromosomes.split("\n").delete_if{ |x|
          x.start_with? '#'
        }.first.chomp
        puts "Single chromosome selected: #{first}"
        `grep "^#{first}\\s" #{inputs[:annotation]} > #{chr1}`
        raise "GTF subsetting failed :(" unless File.exist? chr1
      end
    end

    # run flux and deinterleave the reads for a given number of molecules
    # and reads
    def run_flux(inputs, nmol, nreads)
      if File.exists? 'sim.fastq'
        puts "sim.fastq already exists, skipping simulation"
        puts "(if you want to re-run the simulation, delete sim.fastq)"
      else
        # cleanup previous run
        puts "Removing any leftover files from previous runs"
        `rm sim.*` unless Dir['sim*'].empty?
        # generate param file
        puts "Generating flux simulator parameter file"
        make_flux_params(inputs[:genome], inputs[:annotation], nmol, nreads)
        # run flux simulator
        puts "Simulating reads..."
        `flux-simulator -p sim.par -x -l -s`
        raise "Simulation failed :(" unless File.exists? 'sim.fastq'
        puts "...done simulating reads"
      end
      if File.exist?('left.fq') && File.exist?('right.fq')
        puts "deinterleaved FASTQ files exist, skipping deinterleaving"
      else
        # deinterleave and randomise reads
        puts "Deinterleaving and randomising simulated reads..."
        # here we add to the PATH temporarily to get raw coreutils commands
        # on OSX
        # the coreutils command pipeline simulateously deinterleaves and
        # randomly shuffles the read pairs
        cmd = "#! /usr/bin/env bash\n" \
              "PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH &&"\
              "paste - - - - - - - - < sim.fastq | "\
              "shuf | "\
              "tee >(cut -f 1-4 | tr '\\t' '\\n' > left.fq) | "\
              "cut -f 5-8 | "\
              "tr '\\t' '\\n' > right.fq"
        File.open('split_shuffle.sh', 'w') { |f| f.write cmd }
        File.chmod(0777, 'split_shuffle.sh')
        `./split_shuffle.sh`
        unless File.exists? 'left.fq'
          raise "Failed to deinterleave FASTQ file"
        end
        puts "...done! Reads ready for assembly"
      end
      {
        :left => File.expand_path('left.fq'),
        :right => File.expand_path('right.fq')
      }
    end

    # download Ensembl genome and annotation
    def download_inputs data
      gtf = data[:annotation][:gtf]
      inputs = {}
      if File.exist? gtf
        puts "GTF already exists, skipping download"
      else
        puts "Downloading reference annotation set from Ensembl"
        download(data[:annotation][:url])
        extract('*.gz', '.')
        raise "Couldn't download data from Ensembl" unless File.exist? gtf
      end
      Dir.mkdir 'genome' unless Dir.exists? 'genome'
      Dir.chdir 'genome' do
        if (Dir['*.fa'].empty? && Dir['*.gz'].empty?)
          download(data[:genome][:url])
        else
          puts "Files already in the genome directory, skipping download"
        end
        if (Dir['*.gz'].empty?)
          puts "No gzip files in genome directory - skipping gunzip"
        else
          extract('*.gz', '.')
        end
        rename_chromosome_fastas
        puts "Final list of chromosome files: #{Dir['*fa'].join(', ')}"
      end
      cleanup_gtf gtf
    end

    # remove any chromosomes from the GTF that do not have a FASTA file
    # in the genome directory, as these will crash flux-simulator
    def cleanup_gtf gtf
      puts "Stripping extraneous chromosomes from GTF"
      gtfchroms = `cut -f1 #{gtf} | sort | uniq`.split("\n")
      fachroms = Dir['genome/*fa'].map{ |f| File.basename(f, '.fa') }
      extrachroms = gtfchroms - fachroms
      extrachroms = extrachroms.delete_if{ |x| x.start_with? '#' }
      unless extrachroms.empty?
        puts "These chromosomes are in the GTF but have no FASTA:"
        puts extrachroms.join(', ')
        puts "Removing them from GTF to avoid crashing flux-simulator"
      end
      extrachroms.each do |chrom|
        gtf_strip_chrom(gtf, chrom)
      end
    end

    # remove all entries for a given chromosome from a GTF
    def gtf_strip_chrom gtf, chrom
      tmpgtf = chrom + '.tmp'
      `grep -v "^#{chrom}\\s" #{gtf} > #{tmpgtf}`
      File.rename(tmpgtf, gtf)
    end

    # rename genome fasta files to have just the chromosome name/number
    # by removing the common prefix of all the filenames
    def rename_chromosome_fastas
      prefix = common_prefix(Dir['*.fa'])
      if prefix.length > 0
        fastas = Dir['*.fa']
        fastas.each do |file|
          newfile = file.clone
          newfile.slice! prefix
          File.rename(file, newfile)
        end
        puts "Stripped prefix: #{prefix} from #{fastas.length} FASTA files"
      end
    end

    # return the longest common prefix of an array of strings
    def common_prefix(strings)
      chars  = strings.map(&:chars)
      length = chars.first.zip( *chars[1..-1] ).index{ |a| a.uniq.length>1 }
      strings.first[0,length]
    end

    # generate flux simulator parameter file
    def make_flux_params(genomepath, annotation, nmol, nreads)
      File.open('sim.par', 'w') do |f|
        f.write "REF_FILE_NAME\t#{annotation}\n"\
                "GEN_DIR\t#{genomepath}\n"\
                "NB_MOLECULES\t#{nmol}\n"\
                "POLYA_SCALE\tNaN\n"\
                "POLYA_SHAPE\tNaN\n"\
                "FRAG_SUBSTRATE\tRNA\n"\
                "FRAG_METHOD\tUR\n"\
                "FRAG_UR_ETA\t350\n"\
                "FILTERING\tYES\n"\
                "SIZE_DISTRIBUTION\tN(400, 50)\n"\
                "READ_NUMBER\t#{nreads}\n"\
                "READ_LENGTH\t100\n"\
                "PAIRED_END\tYES\n"\
                "FASTA\tYES\n"\
                "ERR_FILE\t76\n"\
                "UNIQUE_IDS\tYES\n"
      end
    end

    def download(url)
      if @wget
        cmd = "wget #{url}"
      else
        raise RuntimeError.new("wget is not installed")
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
      end
    end

  end # Simulation

end # TransratePaper
