require 'edst/parsers/base_parser'

module EDST
  module Parsers
    # The RootParser is used for parsing all of the other Parser statements
    # once.
    # In order to parse a stream, use the {StreamParser} instead.
    class RootParser < BaseParser
      # (see BaseParser#initialize)
      def initialize(options = {})
        super
        @parsers = []
        @parsers << SpaceParser.new(options)
        @parsers << CommentParser.new(options)
        @parsers << DialogueParser.new(options)
        @parsers << TagParser.new(options)
        @parsers << StringParser.new(options)
        @parsers << LineItemParser.new(options)
        @parsers << LabelParser.new(options)
        @parsers << HeaderParser.new(options)
        @parsers << BlockParser.new(self, options)
        @parsers << WordParser.new(options)
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
