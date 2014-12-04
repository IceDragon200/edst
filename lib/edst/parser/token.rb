require 'edst/core_ext/hash'

module EDST
  class Parser
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

        import(options)
      end

      def children?
        !@children.empty?
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
    end
  end
end
