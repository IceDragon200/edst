require 'edst/parsers/base_parser'

module EDST
  module Parsers
    # The RootParser is used for parsing all of the other Parser statements
    # once.
    # In order to parse a stream, use the {StreamParser} instead.
    class RootParser < BaseParser
      def initialize
        @parsers = []
        @parsers << SpaceParser.new
        @parsers << CommentParser.new
        @parsers << DialogueParser.new
        @parsers << TagParser.new
        @parsers << StringParser.new
        @parsers << LineItemParser.new
        @parsers << LabelParser.new
        @parsers << HeaderParser.new
        @parsers << BlockParser.new(self)
        @parsers << WordParser.new
      end

      # Matches all sub statements once, in order to match a file, use the
      # StreamParser instead.
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        @parsers.each do |p|
          if ast = p.match(ptr, depth + 1)
            #puts "Parsed using: #{p}"
            return ast
          end
        end
        nil
      end
    end
  end
end
