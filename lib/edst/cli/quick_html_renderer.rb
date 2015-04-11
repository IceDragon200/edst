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
    def render_file(filename, options)
      tm = TemplateManager.new
      tm.paths.unshift Dir.getwd
      tm.paths.unshift options.directory

      root = EDST.parse File.read(filename)
      root.children.unshift EDST::AST.new(:comment, value: filename)

      ctx = OpenStruct.new
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
