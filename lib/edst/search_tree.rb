module EDST
  class SearchTree
    class QueryParameter
      # @!attribute kind
      #   @return [String]
      attr_accessor :kind

      # @!attribute key
      #   @return [String]
      attr_accessor :key

      # @!attribute key
      #   @return [String]
      attr_accessor :mode

      # @param [QueryParameter, String] str
      def initialize(str)
        @mode = :nodes
        @key = nil
        @kind = nil
        if str.is_a?(QueryParameter)
          @mode = str.mode
          @kind = str.kind
          @key = str.key
        else
          initialize_from_string(str)
        end
      end

      # @param [String] str
      def initialize_from_string(str)
        case str
        when '>'
          @mode = :next_descendant
        when /(\w+)\.(\w+)/
          @kind = $1
          @key = $2
        else
          @kind = str
        end
      end

      # Tests the query parameter against the given node
      #
      # @param [AST] node
      # @return [Boolean]
      def test?(kind, key)
        return false unless @kind == kind
        return false unless @key == key if @key
        return true
      end
    end

    # @!attribute [r] parent
    #   @return [String]
    attr_reader :parent

    # @param [AST] parent
    def initialize(parent, str, &block)
      @parent = parent
      search str, &block if block
    end

    # Finds children that match the given queries, each query is matched
    # to the next node's child.
    #
    # @param [Array<String>] queries  queries to match against
    # @yieldparam [AST] node  the matches node
    def search_by_query(queries, &block)
      return if queries.empty?
      qs = queries.dup
      query = qs.shift
      early_exit = false
      if query.mode == :next_descendant
        early_exit = true
        query = qs.shift
      end
      subqueries = qs
      @parent.each_child do |node|
        # checks if the current node matches the query
        if query.test?(node.kind.to_s, node.key.to_s)
          if subqueries.empty?
            block.call node
          else
            node.search(subqueries, &block)
          end
        elsif early_exit
          next
        end
        # checks if children match the query
        node.search(queries, &block)
      end
    end

    # Searches the internal node tree
    #
    # @param [String] str
    # @yieldparam [AST] node
    # @return [Enumerator] if not block is given an enumerator is returned
    def search(str, &block)
      str = str.split(/\s+/) unless str.is_a?(Array)
      queries = str.map { |s| QueryParameter.new(s) }
      search_by_query queries, &block
    end
  end
end
