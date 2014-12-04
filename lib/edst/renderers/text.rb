require 'edst/renderers/base'
require 'erubis'

module EDST #:nodoc:
  module TextRenderer
    include BaseRenderer
    # @param [String] str
    # @return [String]
    def edst_escape_text(str)
      edst_escape_y(str) do |k, v|
        case k
        when :ref
          "&:#{v}:"
        when :action
          "*:#{v.upcase}:"
        when :fence
          "`#{v}`"
        end
      end
    end
  end
end
