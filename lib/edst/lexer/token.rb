require 'edst/core_ext/hash'

module EDST
  class Lexer
    class Token
      # debug
      attr_accessor :raw
      attr_accessor :line

      # data
      attr_accessor :kind
      attr_accessor :key
      attr_accessor :value
      attr_accessor :attributes
      attr_accessor :children

      def initialize(kind = :null, **options)
        @kind = kind
        @key = nil
        @value = nil
        @attributes = {}
        @children = []

        import options
      end

      def has_children?
        !@children.empty?
      end

      def each_child(&block)
        @children.each(&block)
      end

      def add_child(child)
        @children.push child
      end

      def to_h
        {
          kind: @kind,
          key: @key,
          value: @value,
          attributes: @attributes,
          children: @children.map(&:to_h),
        }
      end

      def to_token_a
        data = {
          key: @key,
          value: @value,
          attributes: @attributes,
        }
        data[:children] = @children.map(&:to_token_a)
        [@kind, data]
      end

      def import(data)
        @raw = data[:raw] if data.key?(:raw)
        @line = data[:line] if data.key?(:line)
        @kind = data[:kind] if data.key?(:kind)
        @key = data[:key] if data.key?(:key)
        @value = data[:value] if data.key?(:value)
        @attributes = data[:attributes] if data.key?(:attributes)
        @children = data[:children] if data.key?(:children)
      end

      def compare_filter(token, filter)
        case filter
        when /(\w+)\.(\w+)/
          (token.kind.to_s == $1 && token.key.to_s == $2)
        else
          token.kind.to_s == filter
        end
      end

      def search_by_filter(filters)
        result = []
        unless filters.empty?
          filter = filters[0]
          subfilters = filters[1, filters.size - 1]
          each_child do |token|
            if compare_filter(token, filter)
              if subfilters.empty?
                result << token
              else
                result.concat token.search_by_filter(subfilters)
              end
            end
          end
        end
        result
      end

      def search(str)
        filters = str.split(/\s+/)
        search_by_filter filters
      end

      def [](key)
        @attributes[key]
      end

      def []=(key, value)
        @attributes[key] = value
      end
    end
  end
end
