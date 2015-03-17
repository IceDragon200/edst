require 'edst/lexer/token'

module EDST
  class Lexer
    class Containers
      attr_reader :tokens

      def initialize(*objs)
        @handles = objs
        @tokens = []
      end

      def pop
        @handles.pop
      end

      def add_handle(obj)
        @handles << obj
      end

      def add_token(token)
        handle = @handles.last

        case handle
        when Proc  then handle.call(self, token)
        when Array then handle << token
        end

        @tokens << token
      end

      def push(token)
        add_token(token)
      end
    end

    def token(kind, *args)
      token = Token.new(kind, *args)
      yield token if block_given?
      token
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
        token_data = { raw: baseline, line: line_number+1 }

        line = baseline.chomp

        case line
        ##
        # One line dialogue
        #   @ Name "String"
        when /^\s*@\s+(.*)\s+"(.*)"/
          ct.push token(:dialogue, key: $1.strip, value: $2.strip, **token_data)
        ##
        # Multi line dialogue
        #   @ Name "String
        #           Continuing the string"
        when /^\s*@\s+(.*)\s+"(.*)/
          dialogue_token = token(:dialogue, key: $1.strip, value: $2.strip, **token_data)
          ct.push dialogue_token

          ##
          # capture the next tokens raw data, until a " is encountered
          ct.add_handle(lambda do |c, token|
            raw = token.raw
            dialogue_token.value << ' ' << raw.strip.delete('"')
            c.pop if raw.include?('"')
          end)
        ##
        # List Item
        #   --- Item
        when /^\s*---(.*)/
          ct.push token(:ln, value: $1.strip, **token_data)
        ##
        # Label
        #   -- Name --
        when /^\s*--(.*)--/
          ct.push token(:label, value: $1.strip, **token_data)
          last_p_index = line_number
        ##
        # Comment
        #   These comments only work on the start of a blank line,
        #   inline comments are not allowed.
        # # Comment, this is ok
        # Blah de dah # comment, this is not
        when /^\s*#(.*)/
          ct.push token(:comment, value: $1, **token_data)
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
          ct.push token(:header, value: $1.strip, **token_data)
        ##
        # Tag Block
        #   %%key
        #   {
        #
        #   }
        when /^\s*%%(.*)/
          ct.push token(:tag, attributes: { type: 'block' }, key: $1.strip, value: nil, **token_data)
        ##
        # Tag KV
        #   %key value
        when /^\s*%(\S+)(?:\s+(.*))?/
          ct.push token(:tag, attributes: { type: 'flat' }, key: $1.strip, value: $2, **token_data)
        ##
        # It is not some special key then
        else
          cleaned_line = line.strip
          unless cleaned_line == "{" || cleaned_line == "}"
            if cleaned_line.empty?
              ct.push token(:el)
            else
              ct.push token(:p, value: cleaned_line, **token_data)
            end
            last_p_index = line_number
          end
        end

        case line
        when /\{/
          ary = []
          ct.push token(:div, children: ary, **token_data)
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
