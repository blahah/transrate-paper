module TransratePaper

  require 'fixwhich'

  class Fastqc

    attr_reader :data

    def initialize
      @fastqc = which('fastqc').first
      @output = "fastqc_output"
    end

    def run files
      qc = Cmd.new construct_command(files)
      Dir.mkdir(@output) if !Dir.exist?(@output)
      qc.run
    end

    def construct_command(files, threads=8)
      cmd = "#{@fastqc} --kmers 5 --threads #{threads} --extract "
      cmd << "--outdir #{@output} #{files.join(" ")}"
      cmd
    end

    def analyse_output file
      file = File.join(@output, "#{file}_fastqc", "fastqc_data.txt")
      section_name = ""
      headings = []
      @data = {}
      File.open(file).each_line do |line|
        if line =~ /END_MODULE/
          section_name = ""
        elsif line.start_with?('>>')
          section_name, pass = line[2..-2].split("\t")
          @data[section_name] ||= []
          @data[section_name] << { "pass/fail" => pass }
        elsif line.start_with?('#')
          if section_name!=""
            if line =~ /Total/
              cols = line.split("\t")
              @data[section_name] << { cols[0] => cols[1].chomp}
            else
              headings = line[1..-2].split("\t")
            end
          end
        else
          cols = line.split("\t")
          if section_name =~ /Basic/
            @data[section_name] << { cols[0] => cols[1].chomp }
          else
            rowhash = {}
            headings.zip(cols).each do |k, v|
              rowhash[k] = v.chomp
            end
            @data[section_name] << rowhash
          end
        end
      end
      @data
    end

  end # class

end # module