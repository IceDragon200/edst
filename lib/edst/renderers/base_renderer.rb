require_relative '../core_ext/ostruct'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/blank'
require_relative '../parser'
require_relative '../context'
require_relative '../template_manager'
require 'ostruct'
require 'fileutils'
require 'colorize'
require 'tilt'

module EDST
  # Base class for Renderers
  class BaseRenderer
    # @return [Hash<String, BaseRenderer>]
    @@renderers = {}

    attr_accessor :template_name

    # @param [Hash<Symbol, Object>] options
    #   @option options [String] :template_name
    #     Name of the default template to use
    def initialize(**options)
      self.template_name = options.fetch(:template_name)
    end

    # Template names must be in the form of <filename>.<target_ext>.<template_ext>
    # EG.
    #   default.md.erb
    #   layout.html.slim
    #
    # @return [String]
    def default_template_name
      @template_name
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

    # Renders an EDST::AST to the out_stream
    #
    # @param [EDST::AST] doc
    # @param [IO, String] out_stream
    # @param [Hash<Symbol, Object>, OpenStruct] opts
    #   @option opts [String] :filename
    #   @option opts [String] :directory
    #   @option opts [Boolean] :debug
    #   @option opts [EDST::TemplateManager] :template_manager
    # @return [Context] ctx
    def render_doc_to(doc, out_stream, **opts)
      options = OpenStruct.new(opts)
      filename = options.filename
      data = options.data
      tm = options.template_manager
      tm ||= begin
        p = [Dir.getwd]
        p.unshift options.directory if options.directory.present?
        TemplateManager.new paths: p
      end

      ctx = Context.new(document: doc,
        template_manager: tm,
        options: options,
        filename: filename,
        data: data)
      doc.children.unshift EDST::AST.new(:comment, value: filename) if options.debug if filename
      out_stream << tm.render_template(options.template || default_template_name, ctx)

      ctx
    end

    # Parses an EDST stream and renders it as HTML
    #
    # @param [IO, String] in_stream
    # @param [IO, String] out_stream
    # @param [Hash<Symbol, Object>, OpenStruct] opts
    #   @option opts [Hash] :parser_options
    # @return [Context] ctx
    def render_stream_to(in_stream, out_stream, **opts)
      options = OpenStruct.new(opts)
      parser_options = options.parser_options || {}

      root = EDST.parse in_stream, parser_options

      render_doc_to(root, out_stream, **opts)
    end

    # Parses an EDST file `filename` and renders it as HTML
    #
    # @param [String] filename
    # @param [Hash<Symbol, Object>, OpenStruct] opts
    #   @option opts [String] :output_filename
    #     @optional
    #   @option opts [String] :directory
    # @return [void]
    def render_file(filename, **opts)
      options = OpenStruct.new(opts)
      output_filename = opts.fetch(:output_filename) do
        File.join(options.directory,
          File.basename(filename, File.extname(filename)) + output_extname)
      end
      ctx = nil
      File.open(filename, 'r') do |stream|
        FileUtils.mkdir_p File.dirname(output_filename)
        File.open(output_filename, 'w') do |contents|
          ctx = render_stream_to stream, contents, **OpenStruct.conj({ filename: filename }, options).to_h
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
        @@renderers[ext.to_s] = self
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
