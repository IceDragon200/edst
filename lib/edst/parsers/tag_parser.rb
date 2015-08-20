require 'edst/parsers/base_parser'

module EDST
  module Parsers
    # Parses Tag statements.
    # Tags beging with a % and collect everything on their current line.
    # %% also known as block tags have no value, they're entire line is treated
    # as the key, these tags are normally merged with a div.
    class TagParser < BaseParser
      # Matches a tag statement.
      # AST.kind = :tag
      # AST.key = tag name
      # AST.attributes[:type] = tag type ('flat' or 'block')
      # if the tag is a block tag, then the value is nil, otherwise it is
      # rest of the line.
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        return nil unless ptr.scan(/%/)
        start_pos = ptr.pos
        if ptr.scan(/%/)
          AST.new(:tag,
            key: ptr.scan_until(/$/),
            attributes: { type: 'block' }, pos: start_pos)
        else
          key = ptr.scan(/\S+/)
          value = ptr.scan_until(/$/).strip
          AST.new(:tag,
            key: key, value: value,
            attributes: { type: 'flat' }, pos: start_pos)
        end
      end
    end
  end
end
