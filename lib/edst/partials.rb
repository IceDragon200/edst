require_relative 'template_manager'

module EDST
  # Helper module for implementing template partials
  module Partials
    # @!attribute template_manager
    #   @return [TemplateManager]
    attr_accessor :template_manager

    # Renders a template using self as the context
    # see {TemplateManager#render_template}
    #
    # @param [String] name
    # @return [String] rendered content
    def partial(name, *args, &block)
      @template_manager.render_template(name, self, *args, &block)
    end
  end
end
