module TransratePaper

  class Assembly

    def initialize

    end

    def tiny_assembly_sweep(left, right)
      krange = (21..31).step(2)
      range = (1..5).step(2)
      krange.each do |k|
        range.each do |d|
          range.each do |e|
            range.each do |bigd|
              soapdt(k, left, right, d, e, bigd)
            end
          end
        end
      end
    end

    def full_assembly(left, right)
      soapdt(23, left, right, 3, 3, 3)
    end

    def soapdt(k, l, r, d, e, bigd)
      # make config file
      File.open("soapdt.config", "w") do |conf|
        conf.puts "max_rd_len=20000"
        conf.puts "[LIB]"
        conf.puts "avg_ins=#{$opts.insertsize}"
        conf.puts "reverse_seq=0"
        conf.puts "asm_flags=3"
        conf.puts "rank=2"
        conf.puts "fastq1=#{l}"
        conf.puts "fastq2=#{r}"
        if !first
          conf.puts "[LIB]"
          conf.puts "asm_flags=2"
          conf.puts "rank=1" # prioritise the higher-k contigs in scaffolding
          conf.puts "longreads.fa"
        end
      end

      # construct command
      outname = "k#{k}_d#{d}_D#{bigd}_e#{e}"
      soapbin = choose_soapbin k
      cmd = "#{soapbin} all"
      cmd += " -s soapdt.config" # config file
      cmd += " -a 20" # memory assumption
      cmd += " -o #{outname}" # output directory
      cmd += " -K #{k}" # kmer size
      cmd += " -p #{$opts.threads}" # number of threads
      cmd += " -d #{d}" # minimum kmer frequency
      cmd += " -F" # fill gaps in scaffold
      cmd += " -M 1" # strength of contig flattening
      cmd += " -D #{bigd}" # delete edges with coverage no greater than
      cmd += " -L 200" # minimum contig length
      cmd += " -u" # unmask high coverage contigs before scaffolding
      cmd += " -e #{e}" # delete contigs with coverage no greater than
      cmd += " -t 10" # maximum number of transcripts from one locus
      # cmd += " -S" # scaffold structure exists
      puts cmd
      # run command
      `#{cmd} > log.#{outname}.txt`

      # cleanup unneeded files
      `mv #{outname}.scafSeq #{outname}contigs.fa`
      `rm #{outname}.*`
    end

    def choose_soapbin k
      k > 31 ? 'SOAPdenovo-Trans-127mer' : 'SOAPdenovo-Trans-31mer'
    end

  end # Assembly

end # TransratePaper
