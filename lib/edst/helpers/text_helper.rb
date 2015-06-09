require 'edst/core_ext/string'

module EDST
  module Helpers
    module TextHelper
      # Shamlessly stolen from ActionView::Helpers::TextHelper
      # BECAUSE WHO WANTS TO LOAD ALL OF ACTIONVIEW JUST TO GET WORD WRAPPING!
      def word_wrap(text, options = {})
        line_width = options.fetch(:line_width, 80)

        text.split("\n").collect! do |line|
          line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip : line
        end * "\n"
      end

      def edst_escape_yield(str)
        result = str.gsub(/<([^<>]+)>/) { yield :ref, $1 }
        result.gsub!(/\*([^\*]+)\*/) { yield :action, $1 }
        result.gsub!(/`([^`]+)`/) { yield :fence, $1 }
        result
      end

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

      def escape_lines(str, width)
        word_wrap(edst_escape(str.deflate), line_width: width).each_line.map do |line|
          yield line.chomp
        end.join("\n")
      end
    end
  end
end
