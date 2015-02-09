require 'fileutils'

module TransratePaper

  class Assembler

    def initialize data
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
      @data = data
    end

    def run
      @data.each_pair do |sp, spdata|
        expdir = File.join(@gem_dir, "data", sp.to_s)
        # full simulation
        puts "Running full assembly for #{sp}"
        fulldir = File.join(expdir, 'full_assembly')
        FileUtils.mkdir_p fulldir
        Dir.chdir(fulldir) do
          full = spdata[:full]
          full_assembly(full[:left], full[:right])
        end
        # tiny simulation
        #puts "Running tiny assembly sweep for #{sp}"
        #tinydir = File.join(expdir, 'assembly_sweep')
        #FileUtils.mkdir_p tinydir
        #Dir.chdir(tinydir) do
        #  tiny = spdata[:tiny]
        #  left = tiny[:left]
        #  right = tiny[:right]
        #  puts "reads: #{left} & #{right}"
        #  tiny_assembly_sweep(tiny[:left], tiny[:right])
        #end
      end
    end

    def tiny_assembly_sweep(left, right)
      krange = (21..31).step(2)
      range = (1..5).step(2)
      assemblies = []
      krange.each do |k|
        range.each do |d|
          range.each do |e|
            range.each do |bigd|
              assemblies << soapdt(k, left, right, d, e, bigd)
            end
          end
        end
      end
      reference = '../tinysim/reftranscripts.fa'
      transrate(assemblies, left, right, reference)
    end

    def transrate(assemblies, left, right, reference)
      cmd = "transrate "
      cmd << " --assembly #{assemblies.join(',')} "
      cmd << " --left #{left}"
      cmd << " --right #{right}"
      # cmd << " --insertsize 400"
      # cmd << " --insertsd 50"
      cmd << " --reference #{reference}"
      cmd << " --threads 40"
      puts cmd
      `#{cmd} > transrate.log`
    end

    def full_assembly(left, right)
      assembly = soapdt(31, left, right, 3, 3, 3)
      reference = "../simulation/reftranscripts.fa"
      transrate([assembly], left, right, reference)
    end

    def soapdt(k, l, r, d, e, bigd)
      # make config file
      File.open("soapdt.config", "w") do |conf|
        conf.puts "max_rd_len=20000"
        conf.puts "[LIB]"
        conf.puts "avg_ins=400"
        conf.puts "reverse_seq=0"
        conf.puts "asm_flags=3"
        conf.puts "rank=2"
        conf.puts "q1=#{l}"
        conf.puts "q2=#{r}"
      end

      # construct command
      outname = "k#{k}_d#{d}_D#{bigd}_e#{e}"
      soapbin = choose_soapbin k
      cmd = "#{soapbin} all"
      cmd += " -s soapdt.config" # config file
      cmd += " -a 20" # memory assumption
      cmd += " -o #{outname}" # output directory
      cmd += " -K #{k}" # kmer size
      cmd += " -p 40" # number of threads
      cmd += " -d #{d}" # minimum kmer frequency
      cmd += " -F" # fill gaps in scaffold
      cmd += " -M 1" # strength of contig flattening
      cmd += " -D #{bigd}" # delete edges with coverage no greater than
      cmd += " -L 200" # minimum contig length
      cmd += " -u" # unmask high coverage contigs before scaffolding
      cmd += " -e #{e}" # delete contigs with coverage no greater than
      cmd += " -t 10" # maximum number of transcripts from one locus
      # cmd += " -S" # scaffold structure exists
      if File.exist? "#{outname}contigs.fa"
        puts "#{outname}contigs.fa exists, skipping assembly"
      else
        puts cmd
        # run command
        `#{cmd} > log.#{outname}.txt`

        # cleanup unneeded files
        `mv #{outname}.scafSeq #{outname}contigs.fa`
        `rm #{outname}.*`
      end
      "#{outname}contigs.fa"
    end

    def choose_soapbin k
      k > 31 ? 'SOAPdenovo-Trans-127mer' : 'SOAPdenovo-Trans-31mer'
    end

  end # Assembler

end # TransratePaper
