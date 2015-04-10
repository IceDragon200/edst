module EDST
  class AST
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

    def import(data)
      @raw = data[:raw] if data.key?(:raw)
      @line = data[:line] if data.key?(:line)
      @kind = data[:kind] if data.key?(:kind)
      @key = data[:key] if data.key?(:key)
      @value = data[:value] if data.key?(:value)
      @attributes = data[:attributes] if data.key?(:attributes)
      @children = data[:children] if data.key?(:children)
    end

    def compare_filter(node, filter)
      case filter
      when /(\w+)\.(\w+)/
        (node.kind.to_s == $1 && node.key.to_s == $2)
      else
        node.kind.to_s == filter
      end
    end

    def search_by_filter(filters, &block)
      return if filters.empty?
      filter = filters[0]
      subfilters = filters[1, filters.size - 1]
      each_child do |node|
        if compare_filter(node, filter)
          if subfilters.empty?
            block.call node
          else
            node.search_by_filter(subfilters, &block)
          end
        end
      end
    end

    def search(str, &block)
      return to_enum :search unless block
      filters = str.split(/\s+/)
      search_by_filter filters, &block
    end

    def [](key)
      @attributes[key]
    end

    def []=(key, value)
      @attributes[key] = value
    end
  end
end
