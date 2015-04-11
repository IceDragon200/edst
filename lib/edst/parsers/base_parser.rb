module EDST
  module Parsers
    class BaseParser
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

      def debug_log(depth, ptr, msg)
        s, e = prev_line ptr.pos - 1, ptr.string
        s2, e2 = prev_line s - 2, ptr.string
        line = ptr.string[s..e]
        prev_line = ptr.string[s2..e2]
        next_line = (ptr.rest[/\n(.*)$/] || '')
        depth_str = '%-04s' % depth
        puts "#{depth_str} #{' ' * depth}#{self.class} #{msg} .. pos: (#{ptr.pos}/#{ptr.string.size}), prev_line: (#{prev_line.strip}), line: (#{line.strip})"
      end
    end
  end
end
