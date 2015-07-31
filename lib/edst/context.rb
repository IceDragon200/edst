require 'edst/partials'
require 'edst/helpers/text_helper'
require 'edst/helpers/alert'

module EDST
  # Renderer context information
  class Context
    include EDST::Partials
    include EDST::Helpers::TextHelper

    # @!attribute alert
    #   @return [Alert] logger
    attr_accessor :alert

    # @!attribute filename
    #   @return [String] original filename
    attr_accessor :filename

    # @!attribute tree
    #   @return [AST] the ast to render
    attr_accessor :tree

    # @!attribute template_manager
    #   @return [TemplateManager] the template manager
    attr_accessor :template_manager

    # @!attribute asset_exports
    #   @return [Array<String>] files to copy after rendering
    attr_accessor :asset_exports

    # @!attribute options
    #   @return [OpenStruct] options that where used to render the context
    attr_accessor :options

    def initialize
      @alert = Alert.new
    end

    # Copies all found assets to the target options.directory
    def export_assets
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
  end
end
