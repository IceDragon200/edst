require 'strscan'
require_relative 'ast'
require_relative 'ast_processor'
require_relative 'parsers'

module EDST
  # Class for tagging line numbers
  class SourceFile
    # @param [String] string
    def initialize(string)
      start = 0
      @map = []
      string.each_line do |line|
        @map << [line, start...(start + line.size)]
        start += line.size
      end
    end

    # Position in the stream to return its source line
    #
    # @param [Integer] index
    # @return [Array[String, Integer]] line, line_number
    def source_line(index)
      @map.each_with_index do |(s, range), i|
        if range.cover?(index)
          return s, i
        end
      end
      return nil, -1
    end
  end

  # Error raised when the parser hasn't moved from its current location
  # after attempting to match
  class ParserJam < RuntimeError
    # @param [StringScanner] ptr  current string scanner
    # @param [String] n  namespace
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
    def initialize(ptr)
      msg = "Dialogue Text is missing at pos(#{ptr.pos}/#{ptr.string.size})"
      super msg
    end
  end

  # Error raised when a Header is encountered without text.
  class InvalidHeader < RuntimeError
  end

  # Each individual parser for EDST features.
  module Parsers
    #
  end

  # Parses the stream and creates an EDST::AST of it, the resultant
  # AST is unprocessed and will contain loose word and el nodes.
  # Use {.parse} instead if you don't want to manually deal with these loose
  # nodes.
  #
  # @param [String] stream
  # @return [AST]
  def self.parse_bare(stream, options = {})
    string = stream
    string = string.read if string.is_a?(IO)
    ptr = StringScanner.new(string)
    Parsers::StreamParser.new(options).match(ptr)
  rescue Interrupt => ex
    STDERR.puts "Parser interrupted at: (#{ptr.pos}/#{ptr.string.size}), rest: #{ptr.rest}"
    raise ex
  end

  # Adds debug information to the provided node from the given SourceFile
  #
  # @param [SourceFile] source
  # @param [AST] node
  def self.apply_debug(source, node, options)
    node.raw, node.line = source.source_line(node.pos)
    node.filename = options[:filename] if options[:filename]
    node.each_child do |subnode|
      apply_debug(source, subnode, options)
    end
  end

  # Parses the stream and processes it for easy usage.
  #
  # @param [String] stream
  # @return [AST]
  def self.parse(stream, options = {})
    string = stream
    string = string.read if string.is_a?(IO)
    result = AstProcessor.process parse_bare(string, options)
    apply_debug(SourceFile.new(string), result, options) if options[:debug]
    result
  end
end
