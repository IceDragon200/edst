require 'rake/ext/string'
require 'edst/tokenize'
require 'optparse'

module EDST
  module Cli
    module Convert
      def self.run(usrargv)
        squeezer_options = {
          squeezer_p: true
        }

        tokenizer_options = {
          squeezer: squeezer_options
        }

        output_file = '-'

        parser = OptionParser.new do |opt|
          opt.on '-o', '--output-file FILENAME', String, 'Output filename' do |v|
            output_file = v
          end

          opt.on '--[no-]squeeze-p' do |v|
            tokenizer_options[:squeezer][:squeezer_p] = v
          end
        end

        argv = parser.parse!(usrargv.dup)

        if argv.empty?
          tokens = EDST.tokenize(STDIN.read, verbose: false)
          content = EDST.read_token_map(tokens)
          fmt, data = yield(content)
          STDOUT.write(data)
        else
          filename = argv.first

          if filename == '-'
            content = STDIN.read
          else
            content = File.read filename
          end

          tokens = EDST.tokenize content, verbose: false
          result = EDST.read_token_map(tokens)

          fmt, data = yield(result)

          if output_file == '-'
            STDOUT.write data
          else
            if fmt == :binary
              File.open(output_file, 'wb') do |file|
                file.write(data)
              end
            else
              File.write output_file, data
            end
          end
        end
      end
    end
  end
end
