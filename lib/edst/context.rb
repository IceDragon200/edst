require_relative 'partials'
require_relative 'helpers/text_helper'
require_relative 'helpers/alert'

module EDST
  # Renderer context information
  class Context
    include EDST::Partials
    include EDST::Helpers::TextHelper

    # @!attribute alert
    #   @return [EDST::Alert] logger
    attr_accessor :alert

    # @!attribute filename
    #   @return [String] original filename
    attr_accessor :filename

    # @!attribute document
    #   @return [EDST::AST] the ast to render
    attr_accessor :document

    # @!attribute template_manager
    #   @return [EDST::TemplateManager] the template manager
    attr_accessor :template_manager

    # @!attribute asset_exports
    #   @return [Array<String>] files to copy after rendering
    attr_accessor :asset_exports

    # @!attribute options
    #   @return [OpenStruct] options that where used to render the context
    attr_accessor :options

    # @!attribute data
    #   @return [Object] data  anything goes here
    attr_accessor :data

    def initialize(**opts)
      self.filename = opts[:filename]
      self.options = opts.fetch(:options) { {} }
      self.template_manager = opts.fetch(:template_manager)
      self.document = opts.fetch(:document)
      self.data = opts[:data]
      self.alert = Alert.new
      self.asset_exports = []
    end

    # @return [EDST::AST]
    # @deprecated
    def tree
      warn "DEPRECATED: Use #document instead"
      document
    end

    # @param [EDST::AST] doc
    # @deprecated
    def tree=(doc)
      warn "DEPRECATED: Use #document= instead"
      self.document = doc
    end

    # Copies all found assets to the target options.directory
    def export_assets
      dirname = File.dirname(filename)
      asset_exports.each do |pair|
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
  end
end
