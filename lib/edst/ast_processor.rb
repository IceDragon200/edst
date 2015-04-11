require 'active_support/core_ext/object/blank'

module EDST
  module AstProcessor
    def self.merge_words(asts)
      i = 0
      result = []
      last = nil
      fl = lambda do
        if last
          last.value = last.value.join(' ')
          last = nil
        end
      end
      asts.each do |ast|
        if ast.kind == :word
          last ||= begin
            l = AST.new(:p, value: [])
            result << l
            l
          end
          last.value << ast.value
        else
          fl.call
          result << ast
        end
        ast.children = merge_words ast.children
      end
      fl.call
      result
    end

    def self.merge_p(asts)
    end

    def self.merge_ln(asts)
    end

    def self.merge_tag_div(asts)
    end

    def self.cleanup(asts)
    end

    def self.merge_asts(asts)
      asts = merge_words asts
      #asts = merge_p asts
      #asts = merge_ln asts
      #asts = merge_tag_div asts
      #asts = cleanup asts
      i = 0
      result = []
      last_list = nil
      last_p = nil
      while i < asts.size
        ast = asts[i]
        t = ast.dup
        last_list = nil unless t.kind == :ln
        last_p = nil unless t.kind == :p
        case t.kind
        when :p, :string
          v = t.value
          v = v.dump if t.kind == :string
          if last_p
            last_p.value = last_p.value + " " + v
            t = nil
          else
            # ensure that the element is a p
            last_p = t.dup
            last_p.kind = :p
            last_p.value = v
            result << last_p
            t = nil
          end
        when :ln
          if last_list
            last_list.add_child t
            t = nil
          else
            last_list = EDST::AST.new(:list, children: [t])
            result << last_list
            t = nil
          end
        when :label
          if t.value.blank?
            t.kind = :split
          end
        when :tag
          if t[:type] == 'block'
            i += 1
            oi = i
            until asts[i].kind == :div
              fail unless i < asts.size
              i += 1
            end
            tks = asts[oi, i - oi]
            d = asts[i]
            t.kind = :div
            t.children = t.children + tks + d.children
            t.attributes.delete(:type)
          end
        when :el
          t = nil
        end
        if t
          t.children = merge_asts t.children
          result << t
        end
        i += 1
      end
      result
    end

    def self.process(ast)
      ast.dup.tap do |a|
        a.children = merge_asts a.children
      end
    end
  end
end
