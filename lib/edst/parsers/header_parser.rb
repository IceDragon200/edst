require 'edst/parsers/base_parser'

module EDST
  module Parsers
    # Headers are statements beginning with a ~, they have no realy purpose
    # are usually followed by a block tag.
    # These statements come in handy though for marking off a file.
    class HeaderParser < BaseParser
      # Matches Header statements.
      # AST.kind = :header
      # AST.value = header statement
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        return nil unless ptr.scan(/\~/)
        start_pos = ptr.pos
        if head = ptr.scan(/\S+/)
          AST.new(:header, value: head, pos: start_pos)
        else
          raise InvalidHeader, "Headers must have at least 1 word"
        end
      end
    end
  end
end
