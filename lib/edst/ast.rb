require 'edst/search_tree'

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
    # @!attribute pos
    #   @return [Integer] position in original stream
    attr_accessor :pos
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
      @raw = nil
      @line = nil
      @kind = kind
      @key = nil
      @value = nil
      @attributes = {}
      @children = []

      import options
    end

    # Initializes a copy
    #
    # @param [AST] other
    # @return [self]
    def initialize_copy(other)
      @raw = other.raw
      @line = other.line
      @pos = other.pos
      @kind = other.kind
      @key = other.key
      @value = other.value
      @attributes = other.attributes.dup
      @children = other.children.dup
      self
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
      @raw        = data[:raw]        if data.key?(:raw)
      @line       = data[:line]       if data.key?(:line)
      @pos        = data[:pos]        if data.key?(:pos)
      @kind       = data[:kind]       if data.key?(:kind)
      @key        = data[:key]        if data.key?(:key)
      @value      = data[:value]      if data.key?(:value)
      @attributes = data[:attributes] if data.key?(:attributes)
      @children   = data[:children]   if data.key?(:children)
    end

    # Searches the node's children for nodes that match the given query str.
    # The str will be split by spaces and passed in {#search_by_query}.
    #
    # @param [String] str
    # @yieldparam [AST] node
    # @return [Enumerator] if not block is given an enumerator is returned
    def search(str, &block)
      return to_enum :search, str unless block
      SearchTree.new(self, str, &block)
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
