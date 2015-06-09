require 'active_support/core_ext/string'
require 'active_support/core_ext/object/blank'
require 'edst/parser'
require 'edst/cli/common'
require 'edst/template_manager'
require 'pp'
require 'ostruct'
require 'fileutils'
require 'colorize'
require 'tilt'

module EDST
  # Base class for Renderers
  class BaseRenderer
    @@renderers = {}

    # @return [String]
    # @abstract
    def default_template_name
      fail
    end

    # File extension for the renderer output files
    #
    # @return [String]
    def output_extname
      # given, template.md.erb
      # the following will first remove the .erb extension and then return
      # the .md extension.
      # tl;dr: it returns the second extension in a filename
      File.extname(File.basename(default_template_name,
        File.extname(default_template_name)))
    end

    # @param [EDST::Context] ctx
    # @param [String] filename
    # @param [Hash] options
    def export_assets(ctx, filename, options)
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

    # Parses an EDST file `filename` and renders it as HTML
    #
    # @param [String] filename
    # @param [Hash<Symbol, Object>] options
    # @return [void]
    def render_file(filename, options = {})
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

      result = tm.render_template(options.template || default_template_name, ctx)
      basename = File.basename(filename, File.extname(filename))
      out = File.join(options.directory, basename + output_extname)

      puts "\tRENDER #{out}".colorize(:light_green)
      File.write(out, result)

      export_assets ctx, filename, options
    end

    # (see #render_file)
    def self.render_file(filename, options)
      new.render_file filename, options
    end

    # Registers the renderer class for the given extnames
    #
    # @param [String] extnames
    def self.register(*extnames)
      extnames.each do |ext|
        @@renderers[ext] = self
      end
    end

    # Retrieves a renderer for the given extname
    #
    # @param [String] extname
    # @return [Class<BaseRenderer>]
    def self.[](extname)
      @@renderers[extname]
    end
  end
end
