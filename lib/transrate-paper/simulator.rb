module TransratePaper

  class Simulation

    require 'fileutils'
    require 'yaml'

    def initialize
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
      @data = YAML.load_file File.join(@gem_dir, 'data.yaml')
    end

    # run flux capacitor simulation for each species
    def run
      @data.each do |name, data|
        if data.has_key? :sim_inputs
          puts "Preparing to simulate reads for #{name.to_s}"
          thissim = data[:sim_inputs]
          # change to experiment dir
          datadir = File.join(@gem_dir, "data", name.to_s, 'sim_inputs')
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
          Dir.mkdir 'simulation' unless Dir.exist? 'simulation'
          Dir.chdir 'simulation' do
            if File.exists? 'sim.fastq'
              puts "sim.fastq already exists for full simulation, skipping"
              puts "(if you want to re-run the simulation, delete sim.fastq)"
            else
              puts "Simulating large read set (5 million reads)"
              run_flux(full_inputs, 10_000_000, 5_000_000)
            end
            inputs[:full] = inputs[:full].merge {
              :left => File.expand_path 'left.fq'
              :right => File.expand_path 'right.fq'
            }
          end
          # create dir for mini simulation and run it
          Dir.mkdir 'tinysim' unless Dir.exist? 'tinysim'
          Dir.chdir 'tinysim' do
            if File.exists? 'sim.fastq'
              puts "sim.fastq already exists for full simulation, skipping"
              puts "(if you want to re-run the simulation, delete sim.fastq)"
            else
              puts "Simulating small read set (5 hundred thousand reads) " +
                   "from a single chromosome"
              make_tiny_inputs inputs[:full]
              run_flux(tiny_inputs, 2_000_000, 500_000)
            end
            inputs[:tiny] = {
              :genome => inputs[:full][:genome],
              :annotation =>  File.join(datadir, 'chr1.gtf')
              :left => File.expand_path 'left.fq'
              :right => File.expand_path 'right.fq'
            }
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

    # run flux and deinterleave the reads for a given number of molecules and reads
    def run_flux(inputs, nmol, nreads)
      # cleanup previous run
      puts "Removing any leftover files from previous runs"
      `rm sim.*`
      # generate param file
      puts "Generating flux simulator parameter file"
      make_flux_params simdata
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
        :left => File.expand_path 'left.fq',
        :right => File.expand_path 'right.fq'
      }
    end

    # download Ensembl genome and annotation
    def download_inputs data
      gtf = thissim[:annotation][:gtf]
      inputs = {}
      if File.exist? gtf
        puts "GTF already exists, skipping download"
        puts "(if you want to redownload reference, delete the GTF)"
      else
        puts "Downloading reference set from Ensembl"
        download(thissim[:annotation][:url], gtf)
        extract('*.gz', '.')
        Dir.mkdir 'genome' unless Dir.exists? 'genome'
        Dir.chdir 'genome' do
          download(thissim[:genome][:url])
          extract('*.gz', '.')
        end
      end
    end

    # generate flux simulator parameter file
    def make_flux_params(nmol, nreads, genomepath, annotation)
      File.open('sim.par', 'wx') do |f|
        f.write "REF_FILE_NAME\t#{annotation}"\
                "GEN_DIR\t#{genomepath}"\
                "NB_MOLECULES\t#{nmol}"\
                "POLYA_SCALE\tNaN"\
                "POLYA_SHAPE\tNaN"\
                "FRAG_SUBSTRATE\tRNA"\
                "FRAG_METHOD\tUR"\
                "FRAG_UR_ETA\t350"\
                "FILTERING\tYES"\
                "SIZE_DISTRIBUTION\tN(400, 50)"\
                "READ_NUMBER\t#{nreads}"\
                "READ_LENGTH\t100"\
                "PAIRED_END\tYES"\
                "FASTA\tYES"\
                "ERR_FILE\t76"\
                "UNIQUE_IDS\tYES"
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
      end
    end

  end # Simulation

end # TransratePaper
