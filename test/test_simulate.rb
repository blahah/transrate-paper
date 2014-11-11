require 'helper'
require 'tmpdir'
require 'open3'

class TestSimulate < Test::Unit::TestCase

  context "Simulate" do

    setup do
      reference = File.join(File.dirname(__FILE__), 'data', 'reference.fa')
      @simulator = TransratePaper::Simulator.new(reference, 100, 200, 50)
    end

    teardown do
    end

    should "simulate fastq reads" do
      Dir.mktmpdir do |tmpdir|
        Dir.chdir tmpdir do
          @simulator.simulate "test"
          assert File.exist?("test.l.fq")
          assert File.exist?("test.r.fq")
        end
      end
    end

    should "simulate reads and run transrate with them" do
      Dir.mktmpdir do |tmpdir|
        Dir.chdir tmpdir do
          reference = File.join(File.dirname(__FILE__), 'data', 'rice_medium.fa')
          simulator = TransratePaper::Simulator.new(reference, 100, 200, 50)
          simulator.simulate "rice"
          cmd = "transrate --assembly #{reference}"
          cmd << " --left #{tmpdir}/rice.l.fq"
          cmd << " --right #{tmpdir}/rice.r.fq"
          cmd << " --outfile rice"
          stdout, stderr, status = Open3.capture3 cmd
          if stdout =~ /TRANSRATE.ASSEMBLY.SCORE:.([0-9\.]+)/
            score = $1.to_f
            assert score > 0.9, "transrate score is good"
          end
        end
      end
    end
  end
end
