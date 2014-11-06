module TransratePaper

  require 'bio'

  class Simulator

    def initialize reference, density, read_length, fragment_size, fragment_sd
      @reference = reference
      @density = density
      @read_length = read_length
      @fragment_size = fragment_size
      @fragment_sd = fragment_sd
      @random = Random.new(1337)
    end

    # create two fastq files
    def simulate prefix
      transcriptome = Bio::FastaFormat.open(@reference)

      count = 0
      File.open("#{prefix}_1.fastq", "w") do |left|
        File.open("#{prefix}_2.fastq", "w") do |right|
          transcriptome.each do |entry|
            key = entry.definition.split(/\s/).first
            transcripts = [entry.seq, entry.seq.tr("ACGT", "TGCA").reverse]
            transcripts.each do |transcript|
              (0..transcript.length-@read_length).step(@density).each do |pos|
                fragment_size = (@fragment_size + ((@random.rand - 0.5) * @fragment_sd)).round(0)
                if pos + fragment_size < transcript.length
                  bases = transcript[pos..(pos + fragment_size - 1)]
                  # puts "fragment_size:#{fragment_size}\tpos:#{pos}\ttranscript.length:#{transcript.length}"
                  # read 1
                  left.puts "@read:#{count}:#{key}/1"
                  left.puts bases[0..@read_length-1]
                  left.puts "+"
                  left.puts "I"*@read_length
                  # read 2
                  right.puts "@read:#{count}:#{key}/2"
                  right.puts bases[-@read_length..-1].tr("ACGT", "TGCA").reverse
                  right.puts "+"
                  right.puts "I"*@read_length
                  #
                  count+=1
                elsif transcript.length - pos > @read_length * 1.3
                  fragment_size = transcript.length - pos
                  bases = transcript[pos..(pos + fragment_size - 1)]
                  # puts "fragment_size:#{fragment_size}\tpos:#{pos}\ttranscript.length:#{transcript.length}"
                  # read 1
                  left.puts "@read:#{count}:#{key}/1"
                  left.puts bases[0..@read_length-1]
                  left.puts "+"
                  left.puts "I"*@read_length
                  # read 2
                  right.puts "@read:#{count}:#{key}/2"
                  right.puts bases[-@read_length..-1].tr("ACGT", "TGCA").reverse
                  right.puts "+"
                  right.puts "I"*@read_length
                  #
                  count+=1
                end # if
              end # each pos
            end # each transcript
          end
        end # close right
      end # close left

    end # simulate

  end # class

end # module