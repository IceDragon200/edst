require_relative '../core_ext/string'
require_relative '../util'

module EDST
  # Helper modules
  module Helpers
    # Various helper methods for manipulating text
    module TextHelper
      # Word wraps a given string
      #
      # @param [String] text
      # @param [Hash] options
      # @option :options [Integer] :line_width  expected line_width, default: 80
      # @return [String]
      def word_wrap(text, options = {})
        # Shamlessly stolen from ActionView::Helpers::TextHelper
        # BECAUSE WHO WANTS TO LOAD ALL OF ACTIONVIEW JUST TO GET WORD WRAPPING!
        line_width = options.fetch(:line_width, 80)

        text.split("\n").collect! do |line|
          line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip : line
        end * "\n"
      end

      # Finds all edst escape sequences, yields the type and the content,
      # the user then chooses what to replace it with
      #
      # @param [String] str
      # @yieldparam [Symbol] kind  escape sequence kind
      # @yieldparam [String] value  content
      # @yieldreturn [String] string to replace sequence with
      # @return [String]
      def edst_escape_yield(str)
        # <reference>
        result = str.gsub(/<([^<>]+)>/) { yield :ref, $1 }
        # *action*
        result.gsub!(/\*([^\*]+)\*/) { yield :action, $1 }
        # `single tick fence`
        result.gsub!(/`([^`]+)`/) { yield :fence, $1 }
        result
      end

      # Escapes edst using its default action, which is to put back the
      # string (so much for escaping it)
      #
      # @param [String] str
      # @return [String]
      def edst_escape(str)
        edst_escape_yield(str) do |key, value|
          case key
          when :ref
            "<#{value}>"
          when :action
            "*#{value}*"
          when :fence
            "`#{value}`"
          else
            value
          end
        end
      end

      # Escapes and word_wraps the given string by lines.
      #
      # @param [String] str
      # @param [Integer] line_width
      # @return [String]
      def escape_lines(str, line_width)
        word_wrap(
          edst_escape(EDST::Util.deflate(str)),
          line_width: line_width
        ).each_line.map do |line|
          yield line.chomp
        end.join("\n")
      end
    end
  end
end
