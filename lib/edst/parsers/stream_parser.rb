require_relative 'base_parser'

module EDST
  module Parsers
    # The StreamParser is the final and main parser for parsing an entire
    # edst file, though I recommend you just use {EDST.parse} and not bother
    # trying to figure out how to use the class.
    class StreamParser < BaseParser
      # (see BaseParser#initialize)
      def initialize(options = {})
        super
        @root = RootParser.new(options)
      end

      # Matches an entire edst stream, this results in a root AST.
      #
      # @param [StringScanner] ptr
      # @return [AST]
      def match(ptr, depth = 0)
        children = []
        loop do
          ptr.skip(/\s+/)
          break if ptr.eos?
          ptr.unscan if ptr.matched?
          if ast = @root.match(ptr, depth + 1)
            children << ast
          else
            raise ParserJam.new(ptr, "StreamParser[#{depth}]")
          end
        end
        AST.new(:root, children: children, pos: 0)
      end
    end
  end
end
