#!/usr/bin/env ruby

top = {}

# PSL header:
# matches, misMatches, repMatches, nCount, qNumInsert, qBaseInsert, tNumInsert, tBaseInsert, strand, qName, qSize, qStart, qEnd, tName, tSize, tStart, tEnd, blockCount, blockSizes, qStarts, tStarts

class Hit

  attr_reader :qName, :qCov

  def initialize line
    spline = line.split("\t")
    @qName = spline[9]
    @qCov = spline[0].to_i / spline[10].to_f
  end

  def to_s
    [@qName, @qCov].join("\t")
  end

end

# parse in the BLAT psl output file and store the highest coverage hit
# if coverages match, store the highest
File.open(ARGV.first).each_line do |line|
  hit = Hit.new line
  if top.key?(hit.qName)
    prev = top[hit.qName]
    if (prev.qCov < hit.qCov)
      top[hit.qName] = hit
    end
  else
    top[hit.qName] = hit
  end
end

puts "loaded #{top.size} best hits"

File.open(ARGV.first + '.tophits', 'w') do |out|
  out.puts ["qName", "qCov"].join("\t")
  top.each_pair do |k, v|
    out.puts v.to_s
  end
end
