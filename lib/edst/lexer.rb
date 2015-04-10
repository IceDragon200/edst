require 'edst/ast'

module EDST
  class Lexer
    class Containers
      attr_reader :asts

      def initialize(*objs)
        @handles = objs
        @asts = []
      end

      def pop
        @handles.pop
      end

      def add_handle(obj)
        @handles << obj
      end

      def add_ast(ast)
        handle = @handles.last

        case handle
        when Proc  then handle.call(self, ast)
        when Array then handle << ast
        end

        @asts << ast
      end

      def push(ast)
        add_ast(ast)
      end
    end

    def ast(kind, *args)
      ast = AST.new(kind, *args)
      yield ast if block_given?
      ast
    end

    def lex(obj, **options)
      if obj.is_a?(IO)
        str = obj.read
      else
        str = obj
      end

      # external
      result = []

      # internal
      ct = Containers.new(result)
      last_p_index = nil

      str.each_line.each_with_index do |baseline, line_number|
        ast_data = { raw: baseline, line: line_number+1 }

        line = baseline.chomp

        case line
        ##
        # One line dialogue
        #   @ Name "String"
        when /^\s*@\s+(.*)\s+"(.*)"/
          ct.push ast(:dialogue, key: $1.strip, value: $2.strip, **ast_data)
        ##
        # Multi line dialogue
        #   @ Name "String
        #           Continuing the string"
        when /^\s*@\s+(.*)\s+"(.*)/
          dialogue_ast = ast(:dialogue, key: $1.strip, value: $2.strip, **ast_data)
          ct.push dialogue_ast

          ##
          # capture the next asts raw data, until a " is encountered
          ct.add_handle(lambda do |c, ast|
            raw = ast.raw
            dialogue_ast.value << ' ' << raw.strip.delete('"')
            c.pop if raw.include?('"')
          end)
        ##
        # List Item
        #   --- Item
        when /^\s*---(.*)/
          ct.push ast(:ln, value: $1.strip, **ast_data)
        ##
        # Label
        #   -- Name --
        when /^\s*--(.*)--/
          ct.push ast(:label, value: $1.strip, **ast_data)
          last_p_index = line_number
        ##
        # Comment
        #   These comments only work on the start of a blank line,
        #   inline comments are not allowed.
        # # Comment, this is ok
        # Blah de dah # comment, this is not
        when /^\s*#(.*)/
          ct.push ast(:comment, value: $1, **ast_data)
          last_p_index = line_number
        ##
        # Header
        #   This is no longer used, but comes in handy for marking similar
        #   named sections
        # The original syntax was
        #   NAME:NAME
        # V3 has changed it to
        #   ~NAME
        # This allows 1 word Headers :3
        when /^\s*~(\w+(?::\w+)*)/
          ct.push ast(:header, value: $1.strip, **ast_data)
        ##
        # Tag Block
        #   %%key
        #   {
        #
        #   }
        when /^\s*%%(.*)/
          ct.push ast(:tag, attributes: { type: 'block' }, key: $1.strip, value: nil, **ast_data)
        ##
        # Tag KV
        #   %key value
        when /^\s*%(\S+)(?:\s+(.*))?/
          ct.push ast(:tag, attributes: { type: 'flat' }, key: $1.strip, value: $2, **ast_data)
        ##
        # It is not some special key then
        else
          cleaned_line = line.strip
          unless cleaned_line == "{" || cleaned_line == "}"
            if cleaned_line.empty?
              ct.push ast(:el)
            else
              ct.push ast(:p, value: cleaned_line, **ast_data)
            end
            last_p_index = line_number
          end
        end

        case line
        when /\{/
          ary = []
          ct.push ast(:div, children: ary, **ast_data)
          ct.add_handle(ary)
        when /\}/
          ct.pop
        end
      end
      result
    end

    def self.lex(obj, **options)
      new.lex(obj, **options)
    end
  end
end
