module TransratePaper

  class Simulation

    require 'fileutils'
    require 'yaml'
    require 'which'
    include Which

    def initialize
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
      @data = YAML.load_file File.join(@gem_dir, 'data.yaml')
      @curl = which('curl').first
      @wget = which('wget').first
      if !@curl and !@wget
        msg = "Don't know how to download files without curl or wget installed"
        raise RuntimeError.new(msg)
      end
    end

    # run flux capacitor simulation for each species
    def run
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
            if File.exists? 'sim.fastq'
              puts "sim.fastq already exists for full simulation, skipping"
              puts "(if you want to re-run the simulation, delete sim.fastq)"
            else
              puts "Simulating large read set (5 million reads)"
              run_flux(inputs[:full], 10_000_000, 5_000_000)
            end
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
            if File.exists? 'sim.fastq'
              puts "sim.fastq already exists for tiny simulation, skipping"
              puts "(if you want to re-run the simulation, delete sim.fastq)"
            else
              puts "Simulating small read set (5 hundred thousand reads) " +
                   "from a single chromosome"
              make_tiny_inputs inputs[:full]
              run_flux(inputs[:tiny], 2_000_000, 500_000)
            end
          end
        end
      end
      inputs
    end # simulate

    # given a hash of data describing the inputs for a full simulation,
    # extract out a subset of the chromosomes and generate a reference
    # for that
    def make_tiny_inputs inputs
      chromosomes = `cut -f1 #{inputs[:annotation_path]} | sort | uniq`
      first = chromosomes.split("\n").first.chomp
      `grep "^#{first}\s" #{inputs[:annotation_path]} > chr1.gtf`
    end

    # run flux and deinterleave the reads for a given number of molecules
    # and reads
    def run_flux(inputs, nmol, nreads)
      puts `pwd`
      # cleanup previous run
      puts "Removing any leftover files from previous runs"
      `rm sim.*`
      # generate param file
      puts "Generating flux simulator parameter file"
      make_flux_params(inputs[:genome], inputs[:annotation], nmol, nreads)
      # run flux simulator
      puts "Simulating reads..."
      `flux-simulator -p sim.par -x -l -s`
      puts "...done simulating reads"
      # deinterleave and randomise reads
      puts "Deinterleaving and randomising simulated reads..."
      cmd = "paste - - - - - - - - < sim.fastq | "\
            "shuf | "\
            "tee >(cut -f 1-4 | tr '\t' '\n' > left.fq) | "\
            "cut -f 5-8 | "\
            "tr '\t' '\n' > right.fq"
      `#{cmd}`
      puts "...done! Reads ready for assembly"
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
        puts "(if you want to redownload reference, delete the GTF)"
      else
        puts "Downloading reference set from Ensembl"
        download(data[:annotation][:url])
        extract('*.gz', '.')
        raise "Couldn't download data from Ensembl" unless File.exist? gtf
        Dir.mkdir 'genome' unless Dir.exists? 'genome'
        Dir.chdir 'genome' do
          download(data[:genome][:url])
          extract('*.gz', '.')
        end
      end
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
      if @curl
        cmd = "curl -O -J -L #{url}"
      elsif @wget
        cmd = "wget #{url}"
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
      end
    end

  end # Simulation

end # TransratePaper
