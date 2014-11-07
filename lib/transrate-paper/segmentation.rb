#!/usr/bin/env ruby

require 'bio'
require 'bindeps'
require 'open3'
require 'distribution'

module Transrate_Paper

  # The Segmentation class tests the segmentation detection function
  # of transrate. Specifically, it runs a simulation experiment for each
  # of the four species in the paper. The simulation works by taking the
  # pubished transcriptome and randomly concatenating a subset of the
  # sequences together in pairs. These become the true positives and the
  # sequences that were not concatenated become the true negatives.
  # Accuracy of the segmentation algorithm is evaluated by mapping the
  # reads to the transcriptome, and for any contig with reads mapping,
  # running the segmentation algorithm. The segmentation calls can then be
  # classified as TP, TN, FP, or FN, and related accuracy statistics calculated.
  #
  # The experiment is repeated for a range of prior probabiities that a
  # sequence will be composed of single segment
  class Segmentation

    def initialize
    end

    def install_dependencies

    end

    # run the segmentation accuracy evaluation analysis
    def run threads
      assemblies = []
      results = {}
      assemblies.each do |assembly|
        results[assembly] = evaluate(assembly, threads)
      end
      results
    end

    # evaluate the accuracy of the segmentation method using the given assembly
    def evaluate(assembly, threads)
      p_chimeras = 0.05
      chimera_assembly, left, right = simulate(assembly, p_chimeras)
      bam = map_reads(chimera_assembly, left, right)
      results = {}
      [0.01, 0.02, 0.05, 0.1].each do |prior|
        results[prior] = test_segmentation(assembly, bam, threads, prior)
      end
      results
    end

    # run segmentation detection for all contigs in the provided assembly
    # using the provided bam file and return the accuracy
    def test_segmentation(assembly, bam, threads, prior)

    end

    # map the given reads to the given assembly
    def map_reads(assembly, left, right)
      `snap index assembly`
      `snap paired `
    end

    # create a set of reads and an assembly that contains chimeras
    # at a specified rate
    def simulate(assembly, p_chimeras)
      left, right = simulate_reads(assembly)
      chimera_assembly = chimerify_assembly(assembly, p_chimeras)
    end

    # given an assembly, concatenate sequences together in pairs
    # until the proportion of the resultant contigs that are chimeras
    # equals p_chimeras. encode whether the contig is chimeric in the
    # FASTA definition line
    def chimerify_assembly(assembly, target_p)
      current_p = 0.0
      orig_assembly = []
      chim_assembly = 'chimerified.' + assembly
      # load original assembly
      Bio::FastaFormat.open(assembly) do |file|
        file.each do |entry|
          orig_assembly << entry
        end
      end
      n_chimeras = 0
      File.open(chim_assembly, 'wb') do |out|
        # generate chimeras
        while current_p < target_p
          # pop two random contigs off the assembly
          l = orig_assembly.delete_at(rand(orig_assembly.length))
          r = orig_assembly.delete_at(rand(orig_assembly.length))
          # create a chimera
          n_chimeras += 1
          chim = l.seq + r.seq
          out.write chim.to_fasta("chimera_#{n_chimeras}")
          current_p = n_chimeras.to_f / orig_assembly.length.to_f
        end
        # write out remaining non-chimeras
        orig_assembly.each do |record|
          out.write record.entry
        end
      end
      return chim_assembly
    end

    # given an assembly, simulate reads from the contigs
    def simulate_reads assembly
      rng = Distribution::Exponential.rng(0.5)
      seqs = []
      # load assembly
      Bio::FastaFormat.open(assembly) do |file|
        file.each do |entry|
          seqs << entry
        end
      end
      seqs.each do |record|
        # pick expression level
        expr = (Math.exp(rng.call) * 100).to_i
        # simmulate reads
        simulate_reads_with_expr(record.seq, expr, record.entry_id)
            end
    end

    # given a sequence and an expression level, simulate reads covering the
    # sequence to the specified level
    def simulate_reads_with_expr(seq, expr, name, prefix='sim_reads', read_length=100)
      left = File.open(prefix + '.l.fq', 'a')
      right = File.open(prefix + '.r.fq', 'a')
      rng = Distribution::Normal.rng(200, 50)
      expr.times do |count|
        fragment = rng.call.to_i
        fragment = read_length + 1 if fragment <= read_length
        len = seq.length
        pos = (rand * (len - fragment + 1)).round(0)
        bases = seq[pos..(pos + fragment - 1)]
        # read 1
        left.puts "@read:#{count}:#{name}/1"
        left.puts bases[0..(read_length - 1)]
        left.puts "+"
        left.puts "I"*read_length
        # read 2
        right.puts "@read:#{count}:#{name}/2"
        right.puts bases[(-read_length)..-1].tr("ACGT", "TGCA").reverse
        right.puts "+"
        right.puts "I"*read_length
        count += 1
      end
      left.close
      right.close
    end

  end

end
