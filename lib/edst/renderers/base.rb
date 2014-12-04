require 'edst/helpers'
require 'edst/template_manager'

module EDST #:nodoc:
  module BaseRenderer
    include EDST::Helpers::TextHelper
    include Partials

    # @return [Boolean] flag for inlining css into the html instead of linking
    attr_accessor :inline

    # @param [Hash<Symbol, Object>] options
    def init_renderer(**options)
      @inline = false
      @template_manager = options[:template_manager]
    end

    # @abstract
    def render
      #
    end
  end
end
