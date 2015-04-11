require 'edst/ast'
require 'edst/ast_processor'
require 'strscan'

module EDST
  # Error raised when the parser hasn't moved from its current location
  # after attempting to match
  class ParserJam < RuntimeError
    def initialize(ptr, n = nil)
      msg = "Jam at pos(#{ptr.pos}/#{ptr.string.size})"
      msg = "#{n} #{msg}" if n
      msg = "#{msg}, rest: #{ptr.rest.dump}"
      super msg
    end
  end

  # DialogueTextMissing is raised when a Dialogue is created without a String
  # for the text
  class DialogueTextMissing < RuntimeError
  end

  # Error raised when a Header is encountered without text.
  class InvalidHeader < RuntimeError
  end

  # Each individual parser for EDST features.
  module Parsers
    # Parses EDST strings, strings can be enclosed in double quotes, or
    # backticks.
    class StringParser
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

    # Parses Tag statements.
    # Tags beging with a % and collect everything on their current line.
    # %% also known as block tags have no value, they're entire line is treated
    # as the key, these tags are normally merged with a div.
    class TagParser
      # Matches a tag statement.
      # AST.kind = :tag
      # AST.key = tag name
      # AST.attributes[:type] = tag type ('flat' or 'block')
      # if the tag is a block tag, then the value is nil, otherwise it is
      # rest of the line.
      #
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

    # Parses a Dialogue statement.
    # Dialogues are made up of a "@ Speaker" and string statement.
    # If a Speaker's text is missing a DialogueTextMissing exception is raised.
    class DialogueParser
      def initialize
        @sp = StringParser.new
      end

      # Matches a Dialogue statement.
      # AST.kind = :dialogue
      # AST.key = the speaker
      # AST.value = the text
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr)
        return nil unless '@' == ptr.peek(1)
        ptr.pos += 1
        ptr.skip(/\s+/)
        speaker = ptr.scan(/\S+/)
        #ptr.pos -= 1
        ptr.skip(/\s+/)
        text = @sp.match(ptr)
        raise DialogueTextMissing unless text
        AST.new(:dialogue, key: speaker, value: text.value)
      end
    end

    # Comments start with a # and run until the end of the line.
    # Comments can be rendered in html views just for kicks. :3
    class CommentParser
      # Matches a comment statement.
      # AST.kind = :comment
      # AST.value = the comment
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr)
        return nil unless '#' == ptr.peek(1)
        ptr.pos += 1
        AST.new(:comment, value: ptr.scan_until(/$/))
      end
    end

    # LineItems are the basis to any list form, they begin with ---
    # and anything after that is its value.
    class LineItemParser
      # Matches a LineItem statement
      # AST.kind = :ln
      # AST.value = item name
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr)
        return nil unless '---' == ptr.peek(3)
        ptr.pos += 3
        ptr.skip(/\s+/)
        AST.new(:ln, value: ptr.scan_until(/$/).strip)
      end
    end

    # A label is wrapped between a `--`, in one, its just a fancy string.
    class LabelParser
      # Matches a label statement
      # AST.kind = :label
      # AST.value = label name
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr)
        return nil unless '--' == ptr.peek(2)
        ptr.pos += 2
        ptr.skip(/\s+/)
        AST.new(:label, value: ptr.scan_until(/--/).chop.chop.strip)
      end
    end

    # BlockParser parses block statements, anything between a { }.
    # BlockParsers cannot be used without a root parser
    class BlockParser
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

    # Headers are statements beginning with a ~, they have no realy purpose
    # are usually followed by a block tag.
    # These statements come in handy though for marking off a file.
    class HeaderParser
      # Matches Header statements.
      # AST.kind = :header
      # AST.value = header statement
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
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

    # Anything that doesn't fit into the other parsers usually ends up here.
    class WordParser
      # Matches a none space string, in order to create paragraphs use the
      # AstProcessor to compress the words.
      # AST.kind = :word
      # AST.value = the word
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr)
        if word = ptr.scan(/\S+/)
          AST.new(:word, value: word)
        else
          nil
        end
      end
    end

    # The SpaceParser captures newlines and spits out :el AST, el = empty line.
    # These el tokens are used for breaking paragraphs up, since they
    # cause the ast_processor to flush the paragraph.
    class SpaceParser
      # Generates el AST used for breaking up paragraph elements
      # AST.kind = :el
      # AST.value = whatever space string was scanned.
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr)
        if sp = ptr.scan(/\s+/)
          if sp.gsub(' ', '') =~ /\n\n/
            return AST.new(:el, value: sp)
          end
        end
        nil
      end
    end

    # The RootParser is used for parsing all of the other Parser statements
    # once.
    # In order to parse a stream, use the {StreamParser} instead.
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

      # Matches all sub statements once, in order to match a file, use the
      # StreamParser instead.
      #
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

    # The StreamParser is the final and main parser for parsing an entire
    # edst file, though I recommend you just use {EDST.parse} and not bother
    # trying to figure out how to use the class.
    class StreamParser
      def initialize
        @root = RootParser.new
      end

      # Matches an entire edst stream, this results in a root AST.
      #
      # @param [StringScanner] ptr
      # @return [AST]
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

  # Parses the stream and creates an EDST::AST of it, the resultant
  # AST is unprocessed and will contain loose word and el nodes.
  # Use {.parse} instead if you don't want to manually deal with these loose
  # nodes.
  #
  # @param [String] stream
  # @return [AST]
  def self.parse_bare(stream)
    Parsers::StreamParser.new.match(StringScanner.new(stream))
  end

  # Parses the stream and processes it for easy usage.
  #
  # @param [String] stream
  # @return [AST]
  def self.parse(stream)
    AstProcessor.process parse_bare(stream)
  end
end
