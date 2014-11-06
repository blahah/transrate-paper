require 'helper'

class TestTSA < Test::Unit::TestCase

  context "Transrate-TSA" do

    setup do
      @tsa = TransratePaper::Tsa.new
      @list = "test/data/test_list.txt"
    end

    teardown do

    end

    should "download an assembly from the tsa" do
      assert @tsa.download_tsa_assembly("GAAB"), "download"
      assert File.exist?("data/genbank/GAAB/GAAB.fa"), "file missing"
    end

    ### this test downloads a 4.7GB file so it can't be run all the time
    ### but I ran it once and it worked, honest.
    # should "download an sra from the tsa" do
    #   assert @tsa.download_tsa_sra("GABH", "SRR516083"), "download"
    #   assert File.exist?("data/genbank/GABH/GABH_1.fastq"), "fq file missing"
    # end

    ### these tests were used to generate the tsa_list

    # should "download master genbank files" do
    #   @tsa.download_genbank @list
    #   assert File.exist?("data/genbank/tsa.GAAA.mstr.gbff"), "file missing"
    #   assert File.exist?("data/genbank/tsa.GAAC.mstr.gbff"), "file missing"
    #   assert File.exist?("data/genbank/tsa.GAAG.mstr.gbff"), "file missing"
    # end

    # should "parse genbank files" do
    #   @tsa.download_genbank @list
    #   @tsa.download_data
    # end

  end
end
