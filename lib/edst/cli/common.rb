require 'edst/partials'

module EDST
  # Logging interface for the Renderer
  class Alert
    # @param [Object] args
    # @return [void]
    def fixme(*args)
      puts "FIXME: #{args.join(' ')}".colorize(:light_yellow)
    end
  end

  # Renderer context information
  class Context
    include EDST::Partials

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

    def initialize
      @alert = Alert.new
    end
  end
end
