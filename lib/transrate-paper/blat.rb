module Transrate_Paper

  # The Blat class is responsible for running blat and parsing its output
  class Blat

    def blatcmd(target, query, maxintron=20_000, spliced=false)
      cmd = "blat"
      cmd << " #{target}"
      cmd << " #{query}"
      cmd << " -maxIntron #{maxintron}"
      cmd << " -noHead"
      if spliced
        cmd << " -trimT"
        cmd << " -trimHardA"
        cmd << " -fine"
      end
      cmd
    end

    def assembly_to_genome(mrna, genome, maxintron)
      cmd = Cmd.new blatcmd(genome, mrna, maxintron, true)
      cmd.run
    end

    def assembly_to_transcriptome(assembly, transcriptome)
      cmd = Cmd.new blatcmd(transcriptome, assembly)
      cmd.run
    end

  end

end
