require 'edst/parsers/base_parser'

module EDST
  module Parsers
    # The SpaceParser captures newlines and spits out :el AST, el = empty line.
    # These el tokens are used for breaking paragraphs up, since they
    # cause the ast_processor to flush the paragraph.
    class SpaceParser < BaseParser
      # Generates el AST used for breaking up paragraph elements
      # AST.kind = :el
      # AST.value = whatever space string was scanned.
      #
      # @param [StringScanner] ptr
      # @return [AST, nil]
      def match(ptr, depth = 0)
        start_pos = ptr.pos
        if sp = ptr.scan(/\s+/)
          if sp.gsub(' ', '') =~ /\n\n/
            return AST.new(:el, value: sp, pos: start_pos)
          end
        end
        nil
      end
    end
  end
end
