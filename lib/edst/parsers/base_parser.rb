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
      def prev_line(pos, str)
        s = pos
        e = s
        nl = /[\n\r]/

        until str[s] =~ nl
          break s = 0 if s <= 0
          s -= 1
        end
        s += 1 if str[s] =~ nl

        until str[e] =~ nl
          break e = str.size if e >= str.size
          e += 1
        end
        e -= 1 if str[e] =~ nl

        return s, e
      end

      # Returns a string for debugging context information
      #
      # @return [String]
      # @api
      def context_str(ctx)
        "#{self.class}(##@id).ctx(##{ctx.id})[#{ctx.depth}]"
      end

      # Returns a prefix string for debugging
      #
      # @return [String]
      # @api
      def context_debug_str(ctx)
        depth_str = '%-04s' % ctx.depth
        "#{' ' * ctx.depth}#{context_str(ctx)}"
      end

      # Prints debug information out to the console.
      #
      # @param [OpenStruct] ctx  debug context
      # @param [StringScanner] ptr
      # @param [String] msg
      # @api
      def debug_log(ctx, ptr, msg)
        s, e = prev_line ptr.pos - 1, ptr.string
        s2, e2 = prev_line s - 2, ptr.string
        line = ptr.string[s..e]
        prev_line = ptr.string[s2..e2]
        next_line = (ptr.rest[/\n(.*)$/] || '')
        puts "#{context_debug_str(ctx)} #{msg} .. pos: (#{ptr.pos}/#{ptr.string.size}), prev_line: (#{prev_line.strip}), line: (#{line.strip})"
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
