require 'edst/version'
require 'edst/navigation'
require 'yajl'

module EDST
  module Navigation
    module Cli
      def self.run(src_filename, argv)
        STDOUT.puts Dir.getwd

        opts = {
          output: 'navigate.json'
        }

        generate_options = {
          chapter_per_cluster_n: 6,
          basename_fmt: 'ch%03d'
        }

        parser = OptionParser.new do |op|
          op.on '-v', '--verbose', 'Set to verbose output' do |v|
            opts[:verbose] = v
          end

          op.on '-o', '--output-file FILENAME', String, 'Output filename' do |v|
            opts[:output] = v
          end

          op.on '-c', '--chapter_per_cluster NUM', Integer, 'Chapters per cluster' do |v|
            generate_options[:chapter_per_cluster_n] = v
          end

          op.on '-h', '--help' do |v|
            opts[:help] = v
          end
        end

        argv = parser.parse!(ARGV.dup)

        if opts[:help]
          abort "USAGE: #{src_filename} [-v] [-o FILENAME] [<filename>]"
        end

        if opts[:verbose]
          STDERR.puts "PWD: #{Dir.getwd}"
          STDOUT.puts 'Generating Navigation index'
        end

        edsts = Dir.glob('ch*.edst').sort
        data = Navigation.generate(edsts, generate_options)
        File.write opts[:output], Yajl::Encoder.encode(data)
      end
    end
  end
end
