module TransratePaper

  require 'bio'
  require 'distribution'

  class Simulator

    def initialize reference, read_length, fragment_size, fragment_sd
      @reference = reference
      @read_length = read_length
      @fragment_size = fragment_size
      @fragment_sd = fragment_sd
      Kernel.srand(1337)
    end

    # create two fastq files
    def simulate prefix
      transcriptome = Bio::FastaFormat.open(@reference)
      rng = Distribution::Exponential.rng(0.5)
      maxrng = Distribution::Normal.rng(40_000, 3000)
      count = 0
      @left = "#{prefix}.l.fq"
      @right = "#{prefix}.r.fq"
      if !File.exist?(@left)
        File.delete(@right) if File.exist?(@right)
        transcriptome.each do |entry|
          key = entry.definition.split(/\s/).first
          expr = (Math.exp(rng.call) * entry.seq.length * 0.01).to_i
          expr = [expr, (30 * entry.seq.length / @read_length).to_i].max
          expr = [expr, maxrng.call.to_i].min
          simulate_reads_with_expr(entry.seq, expr, key, prefix)
        end
      end
      [@left, @right]
    end # simulate

    def simulate_reads_with_expr(seq, expr, name, prefix)
      left = File.open(@left, 'a')
      right = File.open(@right, 'a')
      rng = Distribution::Normal.rng(@fragment_size, @fragment_sd)
      read_length = @read_length
      read_length = seq.length - 1 if read_length >= seq.length
      expr.times do |count|
        fragment = rng.call.to_i
        fragment = (seq.length - 1) if fragment >= seq.length
        fragment = read_length + 1 if fragment < read_length
        len = seq.length
        pos = (rand * (len - fragment + 1)).to_i
        bases = seq[pos..(pos + fragment - 1)]
        # read 1
        left.puts "@read:#{count}:#{name}:#{pos}/1"
        left.puts bases[0..(read_length - 1)]
        left.puts "+"
        left.puts "I" * read_length
        # read 2
        right.puts "@read:#{count}:#{name}:#{pos}/2"
        right.puts bases[(-read_length)..-1].tr("ACGT", "TGCA").reverse
        right.puts "+"
        right.puts "I" * read_length
      end
      left.close
      right.close
    end

  end # class

end # module