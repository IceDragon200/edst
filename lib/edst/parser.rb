require 'edst/ast'
require 'strscan'

module EDST
  module Parsers
    class StringParser
      def char_to_type(char)
        case char
        when '"'  then 'double'
        when '\'' then 'single'
        when '`'  then 'backtick'
        end
      end

      def match(ptr)
        case c = ptr.peek(1)
        when '"', '\'', '`'
          ptr.pos += 1
          AST.new(:string, value: ptr.scan_until(/#{c}/).chop,
                           attributes: { type: char_to_type(c) })
        else
          nil
        end
      end
    end

    class TagParser
      def match(ptr)
        return nil unless '%' == ptr.peek(1)
        ptr.pos += 1

        if '%' == ptr.peek(1)
          ptr.pos += 1
          AST.new(:tag, key: ptr.scan_until(/$/), value: nil, attributes: { type: 'block' })
        else
          key = ptr.scan /\S+/
          ptr.skip(/\s+/)
          value = ptr.scan_until(/$/)
          AST.new(:tag, key: key, value: value, attributes: { type: 'flat' })
        end
      end
    end

    class DialogueParser
      class DialogueTextMissing < RuntimeError
      end

      def initialize
        @sp = StringParser.new
      end

      def match(ptr)
        return nil unless '@' == ptr.peek(1)
        ptr.pos += 1
        ptr.skip(/\s+/)
        speaker = ptr.scan(/\S+/)
        ptr.skip(/\s+/)
        text = @sp.match(ptr)
        raise DialogueTextMissing unless text
        AST.new(:dialogue, key: speaker, value: text.value)
      end
    end

    class RootParser
      def initialize
        @parsers = []
        @parsers << DialogueParser.new
        @parsers << StringParser.new
        @parsers << TagParser.new
      end

      def match(ptr)
        @parsers.each do |p|
          if ast = p.match(ptr)
            return ast
          end
        end
        nil
      end
    end
  end

  class Parser
  end
end