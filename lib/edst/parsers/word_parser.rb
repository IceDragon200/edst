require 'edst/parsers/base_parser'

module EDST
  module Parsers
    # Anything that doesn't fit into the other parsers usually ends up here.
    class WordParser < BaseParser
      # Matches a none space string, in order to create paragraphs use the
      # AstProcessor to compress the words.
      # AST.kind = :word
      # AST.value = the word
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        start_pos = ptr.pos
        if word = ptr.scan(/\S+/)
          AST.new(:word, value: word, pos: start_pos)
        else
          nil
        end
      end
    end
  end
end
