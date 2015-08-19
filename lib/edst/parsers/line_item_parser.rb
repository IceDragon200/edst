require 'edst/parsers/base_parser'

module EDST
  module Parsers
    # LineItems are the basis to any list form, they begin with ---
    # and anything after that is its value.
    class LineItemParser < BaseParser
      # Matches a LineItem statement
      # AST.kind = :ln
      # AST.value = item name
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        return nil unless ptr.scan(/---/)
        start_pos = ptr.pos
        AST.new(:ln, value: ptr.scan_until(/$/).strip, pos: start_pos)
      end
    end
  end
end
