module EDST
  # Main class for describing the data in EDST.
  class AST
    # @!group Debugging
    # @!attribute raw
    #   @return [String] original string before processing
    attr_accessor :raw
    # @!attribute line
    #   @return [Integer] line number
    attr_accessor :line
    # @!endgroup

    # @!group Data
    # @!attribute kind
    #   @return [Symbol] the kind of node
    attr_accessor :kind
    # @!attribute key
    #   @return [String, nil] generic key value of the node
    attr_accessor :key
    # @!attribute value
    #   @return [String, nil] generic key value
    attr_accessor :value
    # @!attribute attributes
    #   @return [Hash<Symbol, Object>] metadata of the node
    attr_accessor :attributes
    # @!attribute children
    #   @return [Array<AST>] the children of the node
    attr_accessor :children
    # @!endgroup

    # @param [Symbol] kind  kind of node
    # @param [Hash<Symbol, Object>] options  initializer options
    def initialize(kind = :null, **options)
      @kind = kind
      @key = nil
      @value = nil
      @attributes = {}
      @children = []

      import options
    end

    # Does this node have any children?
    #
    # @return [Boolean]
    def has_children?
      !@children.empty?
    end

    # Yields each child in this node.
    #
    # @yieldparam [AST] child
    # @return [Enumerator] if no block is given
    def each_child(&block)
      @children.each(&block)
    end

    # Adds the child to the node as its child
    #
    # @param [AST] child
    # @return [void]
    def add_child(child)
      @children.push child
    end

    # Returns the data of the node, debug data is excluded.
    #
    # @return [Hash<Symbol, Object>]
    def to_h
      {
        kind: @kind,
        key: @key,
        value: @value,
        attributes: @attributes,
        children: @children.map(&:to_h),
      }
    end

    # Sets the data of the node from `data`
    #
    # @param [Hash<Symbol, Object>] data
    # @return [void]
    def import(data)
      @raw = data[:raw] if data.key?(:raw)
      @line = data[:line] if data.key?(:line)
      @kind = data[:kind] if data.key?(:kind)
      @key = data[:key] if data.key?(:key)
      @value = data[:value] if data.key?(:value)
      @attributes = data[:attributes] if data.key?(:attributes)
      @children = data[:children] if data.key?(:children)
    end

    # Checks if the provided node matches the given filter.
    # The filter can take the form of a word, or a dot notation word.
    # If given a dot notation it will match the first word as the node's kind
    # and then the second as its key.
    #
    # @param [AST] node
    # @param [String] filter
    # @api
    #
    # @example
    #   node #=> kind: tag key: age
    #   compare_filter(node, "tag") #=> true
    #   compare_filter(node, "tag.name") #=> false
    def compare_filter(node, filter)
      case filter
      when /(\w+)\.(\w+)/
        (node.kind.to_s == $1 && node.key.to_s == $2)
      else
        node.kind.to_s == filter
      end
    end

    # Finds children that match the given filters, each filter is matched
    # to the next node's child.
    #
    # @param [Array<String>] filters  filters to match against
    # @yieldparam [AST] node  the matches node
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

    # Searches the node's children for nodes that match the given filter str.
    # The str will be split by spaces and passed in {#search_by_filter}.
    #
    # @param [String] str
    # @yieldparam [AST] node
    # @return [Enumerator] if not block is given an enumerator is returned
    def search(str, &block)
      return to_enum :search, str unless block
      filters = str.split(/\s+/)
      search_by_filter filters, &block
    end

    # Delegate for #attributes[]
    #
    # @param [Symbol] key
    # @return [Object] attribute value
    def [](key)
      @attributes[key]
    end

    # Delegate for #attributes[]=
    #
    # @param [Symbol] key
    # @param [Object] value
    # @return [void]
    def []=(key, value)
      @attributes[key] = value
    end
  end
end
