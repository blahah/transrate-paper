#!/usr/bin/env ruby
# blastn -query ../rice_oases.fa -db rice_genome -word_size 10 -gapopen 0 -gapextend 0 -num_threads 8 -out rice_oases_genome.blast -outfmt "6 qseqid sseqid pident qcovs length qlen"
top = {}

class Hit

  attr_reader :qseqid, :sseqid, :pident, :qcovs, :length, :qlen

  def initialize line
    @qseqid, @sseqid, pident, qcovs, length, qlen = line.split("\t")
    @pident = pident.to_f
    @qcovs = qcovs.to_f
    @length = length.to_i
    @qlen = qlen.to_i
  end

  def to_s
    [@qseqid, @qcovs, @pident].join("\t")
  end

end

toolong = 0
nottoolong = 0
# parse in the BLAST output file and store the highest coverage hit
# if coverages match, store the highest
File.open(ARGV.first).each_line do |line|
  hit = Hit.new line
  if hit.length > hit.qlen + 10_000
    toolong += 1
  else
    nottoolong += 1
  end
  # if top.key?(hit.qseqid)
  #   prev = top[hit.qseqid]
  #   if (prev.qcovs < hit.qcovs)
  #     top[hit.qseqid] = hit
  #   elsif (prev.qcovs == hit.qcovs) && (prev.pident < hit.pident)
  #     top[hit.qseqid] = hit
  #   end
  # else
  #   top[hit.qseqid] = hit
  # end
end

puts "#{toolong} too long vs #{nottoolong} not too long"
puts "loaded #{top.size} best hits"

File.open(ARGV.first + '.tophits', 'w') do |out|
  out.puts ["qseqid", "qcovs", "pident"].join("\t")
  top.each_pair do |k, v|
    out.puts v.to_s
  end
end
