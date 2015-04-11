require 'edst/ast'
require 'edst/ast_processor'
require 'strscan'

module EDST
  # Error raised when the parser hasn't moved from its current location
  # after attempting to match
  class ParserJam < RuntimeError
    def initialize(ptr, n = nil)
      msg = "Jammed at pos(#{ptr.pos}/#{ptr.string.size}), rest: #{ptr.rest.dump}"
      msg = "#{n} #{msg}" if n
      super msg
    end
  end

  class DialogueTextMissing < RuntimeError
  end

  class InvalidHeader < RuntimeError
  end

  module Parsers
    class StringParser
      def char_to_type(char)
        case char
        when '"'  then 'double'
        #when '\'' then 'single'
        when '`'  then 'backtick'
        end
      end

      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr)
        case c = ptr.peek(1)
        #when '"', '\'', '`'
        when '"', '`'
          ptr.pos += 1
          AST.new(:string, value: ptr.scan_until(/#{c}/).chop,
                           attributes: { type: char_to_type(c) })
        else
          nil
        end
      end
    end

    class TagParser
      # @param [StringScanner] ptr
      # @return [AST, nil]
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
      def initialize
        @sp = StringParser.new
      end

      # @param [StringScanner] ptr
      # @return [AST, nil]
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

    class CommentParser
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr)
        return nil unless '#' == ptr.peek(1)
        ptr.pos += 1
        AST.new(:comment, value: ptr.scan_until(/$/))
      end
    end

    class LineItemParser
      def match(ptr)
        return nil unless '---' == ptr.peek(3)
        ptr.pos += 3
        ptr.skip(/\s+/)
        AST.new(:ln, value: ptr.scan_until(/$/).strip)
      end
    end

    class LabelParser
      def match(ptr)
        return nil unless '--' == ptr.peek(2)
        ptr.pos += 2
        ptr.skip(/\s+/)
        AST.new(:label, value: ptr.scan_until(/--/).chop.chop.strip)
      end
    end

    # BlockParsers cannot be used without a root parser
    class BlockParser
      def initialize(root)
        @root = root
      end

      def match(ptr)
        return nil unless '{' == ptr.peek(1)
        ptr.pos += 1
        children = []
        loop do
          ptr.skip(/\s+/)
          break if '}' == ptr.peek(1)
          ptr.unscan if ptr.matched?
          if ast = @root.match(ptr)
            children << ast
          elsif !ptr.eos?
            raise ParserJam.new(ptr, 'BlockParser')
          end
        end
        ptr.pos += 1
        AST.new(:div, children: children)
      end
    end

    class WordParser
      def match(ptr)
        if word = ptr.scan(/\S+/)
          AST.new(:word, value: word)
        else
          nil
        end
      end
    end

    class HeaderParser
      def match(ptr)
        return nil unless '~' == ptr.peek(1)
        ptr.pos += 1
        if head = ptr.scan(/\S+/)
          AST.new(:header, value: head)
        else
          raise InvalidHeader, "Headers must have at least 1 word"
        end
      end
    end

    class SpaceParser
      def match(ptr)
        if sp = ptr.scan(/\s+/)
          if sp.gsub(' ', '') =~ /\n\n/
            return AST.new(:el, value: sp)
          end
        end
        nil
      end
    end

    class RootParser
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

      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr)
        @parsers.each do |p|
          if ast = p.match(ptr)
            return ast
          end
        end
        nil
      end
    end

    class StreamParser
      def initialize
        @root = RootParser.new
      end

      def match(ptr)
        children = []
        loop do
          ptr.skip(/\s+/)
          break if ptr.eos?
          ptr.unscan if ptr.matched?
          if ast = @root.match(ptr)
            children << ast
          else
            raise ParserJam.new(ptr, 'StreamParser')
          end
        end
        AST.new(:root, children: children)
      end
    end
  end

  def self.parse_bare(stream)
    Parsers::StreamParser.new.match(StringScanner.new(stream))
  end

  def self.parse(stream)
    AstProcessor.process parse_bare(stream)
  end
end
