require 'edst/parsers/base_parser'

module EDST
  module Parsers
    # A label is wrapped between a `--`, in one, its just a fancy string.
    class LabelParser < BaseParser
      # Matches a label statement
      # AST.kind = :label
      # AST.value = label name
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        return nil unless ptr.scan(/--/)
        ptr.skip(/\s+/)
        value = ptr.scan_until(/--/) || ''
        AST.new(:label, value: value.gsub(/\s*--\s*\z/, '').strip)
      end
    end
  end
end
