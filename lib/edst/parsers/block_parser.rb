require_relative 'base_parser'

module EDST
  module Parsers
    # BlockParser parses block statements, anything between a { }.
    # BlockParsers cannot be used without a root parser
    class BlockParser < BaseParser
      # @param [RootParser] root
      # (see BaseParser#initialize)
      def initialize(root, options = {})
        @root = root
        super options
      end

      # Matches a block/div
      # AST.kind = :div
      # AST.children
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        return nil unless ptr.scan(/\{/)
        start_pos = ptr.pos
        ctx = OpenStruct.new(id: generate_id, depth: depth)
        verbose_debug_log ctx, ptr, "opened"
        children = []
        loop do
          if ptr.scan(/\s*\}/)
            verbose_debug_log ctx, ptr, "closed"
            break
          end
          if ptr.eos?
            raise ParserJam.new(ptr, context_str(ctx))
          elsif ast = @root.match(ptr, depth + 1)
            children << ast
          end
        end
        AST.new(:div, children: children, pos: start_pos)
      end
    end
  end
end
