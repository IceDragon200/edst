require 'edst/core_ext/string'
require 'ostruct'

module EDST
  module Parsers
    class BaseParser
      # @!attribute [r] id
      #   @return [String]
      attr_reader :id

      # @param [Hash<Symbol, Object>] options
      def initialize(options = {})
        @id = generate_id
        @verbose = options.fetch(:verbose, false)
      end

      # Generates a 8 character id, used for debugging
      #
      # @return [String]
      # @api
      def generate_id
        l = %w[a b c d e f A B C D E F 0 1 2 3 4 5 6 7 8 9 0]
        8.times.map { l.sample }.join('')
      end

      # Extracts the previous line points from the str
      #
      # @param [Integer] pos
      # @param [String] str
      # @return [Array<Integer>] the start and end point of the previous line
      # @api
      def prev_line_pos(pos, str)
        s = pos
        e = s
        nl = /[\n\r]/
        s = str.index_of_prev_closest(nl, s)
        e = str.index_of_next_closest(nl, e)
        return s, e
      end

      # Returns the sourrounding lines from the current ptr position
      #
      # @param [StringScanner]
      # @return [Array<String>]
      # @api
      def debug_lines(ptr)
        s, e = prev_line_pos ptr.pos - 1, ptr.string
        s2, e2 = prev_line_pos s - 2, ptr.string
        line = ptr.string[s..e]
        prev_line = ptr.string[s2..e2]
        next_line = ptr.rest[/\n(.*)$/] || ''
        return prev_line, line, next_line
      end

      # Returns a string for debugging context information
      #
      # @param [OpenStruct] ctx
      # @return [String]
      # @api
      def context_str(ctx)
        "#{self.class}(##@id).ctx(##{ctx.id})[#{ctx.depth}]"
      end

      # Returns a prefix string for debugging
      #
      # @param [OpenStruct] ctx
      # @return [String]
      # @api
      def context_debug_str(ctx)
        depth_str = '%-04s' % ctx.depth
        "#{' ' * ctx.depth}#{context_str(ctx)}"
      end

      # Returns the pointer position as a fractional string
      #
      # @param [StringScanner] ptr
      # @return [String]
      # @api
      def ptr_pos_str(ptr)
        "#{ptr.pos}/#{ptr.string.size}"
      end

      # Prints debug information out to the console.
      #
      # @param [OpenStruct] ctx  debug context
      # @param [StringScanner] ptr
      # @param [String] msg
      # @api
      def debug_log(ctx, ptr, msg)
        prev_line, line, next_line = *debug_lines(ptr)
        puts "#{context_debug_str(ctx)} #{msg} .. pos: (#{ptr_pos_str(ptr)}), prev_line: (#{prev_line.strip}), line: (#{line.strip})"
      end

      # (see #debug_log)
      # @api
      def verbose_debug_log(*args)
        return unless @verbose
        debug_log(*args)
      end
    end
  end
end
