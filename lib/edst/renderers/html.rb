require 'edst/renderers/base'
require 'slim'

module EDST #:nodoc:
  module HTMLRenderer
    include BaseRenderer
    # @param [String] str
    # @return [String]
    def edst_escape_html(str)
      edst_escape_y(str) do |k, v|
        %Q(<em class="#{k}">#{v}</em>)
      end
    end
  end
end
