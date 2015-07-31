require 'edst/core_ext/ostruct'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/blank'
require 'edst/parser'
require 'edst/context'
require 'edst/template_manager'
require 'ostruct'
require 'fileutils'
require 'colorize'
require 'tilt'

module EDST
  # Base class for Renderers
  class BaseRenderer
    @@renderers = {}

    # Template names must be in the form of <filename>.<target_ext>.<template_ext>
    # EG.
    #   default.md.erb
    #   layout.html.slim
    #
    # @return [String]
    # @abstract
    def default_template_name
      fail "No default template name set for this renderer"
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

    # Parses an EDST stream and renders it as HTML
    #
    # @param [IO, String] out_stream
    # @param [IO, String] in_stream
    # @param [Hash<Symbol, Object>, OpenStruct] opts
    # @return [[Context, String]] ctx, result
    def render_stream_to(in_stream, out_stream, opts = {})
      options = OpenStruct.new(opts)
      filename = options.filename

      tm = TemplateManager.new
      tm.paths.unshift Dir.getwd
      tm.paths.unshift options.directory

      parser_options = options.parser_options || {}

      root = EDST.parse in_stream, parser_options
      ctx = Context.new
      ctx.options = options
      ctx.tree = root
      ctx.template_manager = tm
      ctx.asset_exports = [] # files that need to be copied as well
      if filename
        root.children.unshift EDST::AST.new(:comment, value: filename)
        ctx.filename = filename
      end
      out_stream << tm.render_template(options.template || default_template_name, ctx)
      ctx
    end

    # Parses an EDST file `filename` and renders it as HTML
    #
    # @param [String] filename
    # @param [Hash<Symbol, Object>, OpenStruct] opts
    # @return [void]
    def render_file(filename, opts = {})
      options = OpenStruct.new(opts)
      output_filename = File.join(options.directory,
        File.basename(filename, File.extname(filename)) + output_extname)
      ctx = nil
      File.open(filename, 'r') do |stream|
        File.open(output_filename, 'w') do |contents|
          ctx = render_stream_to stream, contents, OpenStruct.conj({ filename: filename }, options)
        end
      end
      puts "\tRENDER #{output_filename}".colorize(:light_green)
      ctx.export_assets
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
