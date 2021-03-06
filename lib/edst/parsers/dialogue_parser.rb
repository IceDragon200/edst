require_relative 'base_parser'

module EDST
  module Parsers
    # Parses a Dialogue statement.
    # Dialogues are made up of a "@ Speaker" and string statement.
    # If a Speaker's text is missing a DialogueTextMissing exception is raised.
    class DialogueParser < BaseParser
      # (see BaseParser#initialize)
      def initialize(options = {})
        super
        @sp = StringParser.new
      end

      # Matches a Dialogue statement.
      # AST.kind = :dialogue
      # AST.key = the speaker
      # AST.value = the text
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        return nil unless ptr.scan(/@/)
        start_pos = ptr.pos
        speaker = ptr.scan(/[^"`]+/).strip
        text = @sp.match(ptr, depth + 1)
        raise DialogueTextMissing.new(ptr) unless text
        AST.new(:dialogue, key: speaker, value: text.value, pos: start_pos)
      end
    end
  end
end
