require 'active_support/core_ext/string'
require 'active_support/core_ext/object/blank'
require 'edst'
require 'edst/parser'
require 'edst/template_manager'
require 'pp'
require 'slim'
require 'tilt'
require 'ostruct'
require 'fileutils'
require 'colorize'

module EDST
  class QuickHtmlRenderer
    class Alert
      def fixme(*args)
        puts "FIXME: #{args.join(' ')}".colorize(:light_yellow)
      end
    end

    class Context
      include EDST::Partials

      attr_accessor :alert
      attr_accessor :filename
      attr_accessor :tree
      attr_accessor :template_manager
      attr_accessor :asset_exports

      def initialize
        @alert = Alert.new
      end
    end

    def render_file(filename, options)
      tm = TemplateManager.new
      tm.paths.unshift Dir.getwd
      tm.paths.unshift options.directory

      parser_options = options.parser_options || {}
      root = EDST.parse File.read(filename), parser_options
      root.children.unshift EDST::AST.new(:comment, value: filename)

      ctx = Context.new
      ctx.filename = filename
      ctx.tree = root
      ctx.template_manager = tm
      ctx.asset_exports = [] # files that need to be copied as well

      result = tm.render_template(options.template || 'views/generic.html.slim', ctx)
      basename = File.basename(filename, File.extname(filename))
      out = File.join(options.directory, "#{basename}.html")

      puts "\tRENDER #{out}".colorize(:light_green)
      File.write(out, result)

      dirname = File.dirname(filename)
      ctx.asset_exports.each do |pair|
        src, dest = *pair
        s = File.expand_path(src, dirname)
        d = File.expand_path(dest, options.directory)
        if File.exist?(d)
          puts "\tASSET #{d}".colorize(:light_blue)
        elsif !File.exist?(s)
          puts "\tMISSING ASSET #{s}".colorize(:light_red)
        else
          FileUtils.mkdir_p File.dirname(d)
          FileUtils.cp s, d
          puts "\tNEW ASSET #{d}".colorize(:light_green)
        end
      end
    end

    def self.render_file(filename, options)
      new.render_file filename, options
    end
  end
end
