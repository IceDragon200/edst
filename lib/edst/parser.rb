require 'edst/ast'
require 'edst/ast_processor'
require 'strscan'
require 'edst/parsers'

module EDST
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
    ptr = StringScanner.new(stream)
    Parsers::StreamParser.new(options).match(ptr)
  rescue Interrupt => ex
    STDERR.puts "Parser interrupted at: (#{ptr.pos}/#{ptr.string.size}), rest: #{ptr.rest}"
    raise ex
  end

  # Parses the stream and processes it for easy usage.
  #
  # @param [String] stream
  # @return [AST]
  def self.parse(stream, options = {})
    AstProcessor.process parse_bare(stream, options)
  end
end
