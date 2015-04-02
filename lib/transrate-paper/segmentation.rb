#!/usr/bin/env ruby

require 'bindeps'
require 'json'
require 'yaml'
require 'open3'
require 'fixwhich'

module TransratePaper

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

    def initialize data
      @data = data # description and location of the data
      @gem_dir = Gem.loaded_specs['transrate-paper'].full_gem_path
    end

    def install_dependencies

    end

    def run threads

    end

    # run segmentation detection for all contigs in the provided assembly
    # and return the accuracy
    def test_segmentation(assembly, left, right, threads, prior)

    end

    # given an assembly, concatenate sequences together in pairs
    # until the proportion of the resultant contigs that are chimeras
    # equals p_chimeras. encode whether the contig is chimeric in the
    # FASTA definition line
    def chimerify_assembly(assembly, p_chimeras)

    end

  end

end
