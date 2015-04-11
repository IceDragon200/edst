require 'edst/parsers/base_parser'

module EDST
  module Parsers
    # BlockParser parses block statements, anything between a { }.
    # BlockParsers cannot be used without a root parser
    class BlockParser < BaseParser
      # @param [RootParser] root
      def initialize(root)
        @root = root
      end

      # Matches a block/div
      # AST.kind = :div
      # AST.children
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        return nil unless ptr.scan(/\{/)
        #debug_log depth, ptr, "opened"
        children = []
        loop do
          if ptr.scan(/\s*\}/)
            #debug_log depth, ptr, "closed"
            break
          end
          if ptr.eos?
            raise ParserJam.new(ptr, "BlockParser[#{depth}]")
          elsif ast = @root.match(ptr, depth + 1)
            children << ast
          end
        end
        AST.new(:div, children: children)
      end
    end
  end
end
