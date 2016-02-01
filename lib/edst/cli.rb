require 'edst/renderers'
require 'edst/core_ext/ostruct'
require 'optparse'

module EDST
  module Cli
    class Application
      def initialize(**options)
        @settings = OpenStruct.conj(options,
          live: false,
          directory: Dir.getwd,
          render_engines: [],
          template: ENV['EDST_HTML_TEMPLATE'].presence
        )
      end

      private def run_render(argv)
        if @settings.render_engines.empty?
          @settings.render_engines << 'html'
        end
        @settings.render_engines.uniq!

        renderers = @settings.render_engines.map do |re|
          if renderer = EDST::BaseRenderer[re]
            renderer.new
          else
            abort "Invalid render_engine #{re}"
          end
        end
        renderers.compact!
        renderers.uniq!

        renderers.each do |renderer|
          argv.each do |filename|
            renderer.render_file filename, @settings
          end
        end
      end

      private def run_repl(argv)
        loop do
          begin
            print "Type a thing! > "
            str = STDIN.gets
            if str
              doc = EDST.parse(str)
              puts "\t#{doc.inspect}"
            end
          rescue Interrupt
            break
          rescue => ex
            p ex.inspect
          end
        end
      end

      private def create_parser
        OptionParser.new do |opts|
          opts.on '', '--repl', 'Start a STDIN read loop and parse the results repl' do
            @settings.repl = true
          end

          opts.on '-r', '--render-engines NAME,...', Array, 'Rendering engines, defaults to html' do |v|
            @settings.render_engines.concat v
          end

          opts.on '-d', '--directory NAME', String, 'Output directory' do |v|
            @settings.directory = v
          end

          opts.on '-t', '--template NAME', String, 'Template file' do |v|
            @settings.template = v
          end

          opts.on '-h', '--help', 'Displays this help message' do
            puts opts
            exit
          end
        end
      end

      def run(oargv)
        parser = create_parser
        argv = parser.parse(oargv)

        if @settings.repl
          run_repl argv
        else
          run_render argv
        end
      end

      def self.run(argv, **options)
        new(options).run(argv)
      end
    end
  end
end
