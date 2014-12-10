require 'helper'

class TestTransratePaper < Test::Unit::TestCase

  context "Transrate-Paper" do

    setup do
      @paper = TransratePaper::TransratePaper.new
    end

    teardown do
    end

    should "get extracted name of file" do
      # @paper.download_data
      sra_file = "data/rice/assembly/SRR12345.sra"
      fastq_file  = "data/rice/assembly/SRR12345_1.fastq"
      assert_equal fastq_file, @paper.extracted_name(sra_file)
      tgz_file = "data/rice/assembly/assembly.tar.gz"
      assembly  = "data/rice/assembly/assembly"
      assert_equal assembly, @paper.extracted_name(tgz_file)
    end

  end
end
