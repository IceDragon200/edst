require_relative 'base_parser'

module EDST
  module Parsers
    # Parses EDST strings, strings can be enclosed in double quotes, or
    # backticks.
    class StringParser < BaseParser
      # Pass in a ", or ` and get the name of it
      #
      # @param [String] char
      # @return [String]
      def char_to_type(char)
        case char
        when '"'  then 'double'
        #when '\'' then 'single'
        when '`'  then 'backtick'
        else
          raise "Dunno what to do with a #{char}."
        end
      end

      # Matches an string statement.
      # AST.kind = :string
      # AST.value = tag name
      # AST.attributes[:type] = opening char (" or `)
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        case c = ptr.peek(1)
        when '"', '`'
          start_pos = ptr.pos
          ptr.pos += 1
          AST.new(:string, value: ptr.scan_until(/#{c}/).chop,
                           attributes: { type: char_to_type(c) },
                           pos: start_pos)
        end
      end
    end
  end
end
