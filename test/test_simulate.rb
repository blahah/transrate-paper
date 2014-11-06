require 'helper'
require 'tmpdir'

class TestSimulate < Test::Unit::TestCase

  context "Simulate" do

    setup do
      reference = File.join(File.dirname(__FILE__), 'data', 'reference.fa')
      @simulator = TransratePaper::Simulator.new(reference, 10, 100, 200, 50)
    end

    teardown do
    end

    should "simulate fastq reads" do
      Dir.mktmpdir do |tmpdir|
        Dir.chdir tmpdir do
          @simulator.simulate "test"
          assert File.exist?("test_1.fastq")
          assert File.exist?("test_2.fastq")
        end
      end
    end
  end
end
