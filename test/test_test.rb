require 'helper'

class TestTransratePaper < Test::Unit::TestCase

  context "Transrate-Paper" do

    setup do
      @paper = Transrate_Paper::Transrate_Paper.new
    end

    teardown do
    end

    should "download sra files" do
      @paper.download_data
    end

  end
end
