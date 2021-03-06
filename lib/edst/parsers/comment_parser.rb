require_relative 'base_parser'

module EDST
  module Parsers
    # Comments start with a # and run until the end of the line.
    # Comments can be rendered in html views just for kicks. :3
    class CommentParser < BaseParser
      # Matches a comment statement.
      # AST.kind = :comment
      # AST.value = the comment
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        return nil unless ptr.scan(/#/)
        start_pos = ptr.pos
        AST.new(:comment, value: ptr.scan_until(/$/), pos: start_pos)
      end
    end
  end
end
