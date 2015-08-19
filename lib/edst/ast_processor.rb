require 'active_support/core_ext/object/blank'
require 'edst/ast'

module EDST
  # Module which defines helper methods and classes for processing ASTs
  # and making them somewhat saner.
  module AstProcessor
    # A helper object for creating grouping Processors
    class Grouper
      # Invoke context object for storing information
      class Context
        # @!attribute [rw] result
        #   @return [Array<AST>] the result from the grouping
        attr_accessor :result
        # @!attribute [rw] last
        #   @return [Array<AST>] last note worthy group node
        attr_accessor :last
      end

      # Called when a handle_ast returns false, and you need to do some
      # processing on the last node.
      #
      # @param [Context] ctx
      # @return [void]
      def flush(ctx)
        ctx.last = nil
      end

      # Passes the ast over for handling, if now handling occured, this
      # should return false to break the current group.
      #
      # @param [Context] ctx
      # @param [AST] ast
      # @return [Boolean]
      def handle_ast(ctx, ast)
        false
      end

      # Called when a handle_ast returns true
      #
      # @param [Context] ctx
      # @param [AST] ast
      # @return [void]
      def on_handled(ctx, ast)
      end

      # Called when a handle_ast returns false
      #
      # @param [Context] ctx
      # @param [AST] ast
      # @return [void]
      def on_not_handled(ctx, ast)
        flush(ctx)
        ctx.result << ast
      end

      # Processes the given asts list and attempts to group them.
      #
      # @param [Array<AST>] asts
      def invoke(asts)
        ctx = Context.new
        ctx.result = []
        ctx.last = nil
        asts.each do |ast|
          if handle_ast(ctx, ast)
            on_handled(ctx, ast)
          else
            on_not_handled(ctx, ast)
          end
          ast.children = invoke ast.children
        end
        flush(ctx)
        ctx.result
      end
    end

    # Bunches words together to form paragraphs
    class WordGrouper < Grouper
      # (see Grouper#flush)
      def flush(ctx)
        return unless ctx.last
        # words are normally packed into the p as an Array, they need to be
        # joined back together to form proper paragraphs.
        ctx.last.value = ctx.last.value.join(' ')
        ctx.last = nil
      end

      # (see Grouper#handle_ast)
      def handle_ast(ctx, ast)
        if ast.kind == :word
          ctx.last ||= begin
            AST.new(:p, value: [], pos: ast.pos).tap { |l| ctx.result << l }
          end
          ctx.last.value << ast.value
          return true
        end
        false
      end
    end

    # base class for generic list grouping
    class BaseListGrouper < Grouper
      # @param [Symbol] item_kind  the kind of nodes to group together
      def initialize(item_kind, group_name)
        super()
        @item_kind = item_kind
        @group_name = group_name
      end

      # (see Grouper#handle_ast)
      def handle_ast(ctx, ast)
        if ast.kind == @item_kind
          ctx.last ||= begin
            AST.new(@group_name, pos: ast.pos).tap { |l| ctx.result << l }
          end
          ctx.last.children << ast
          return true
        # we can inject comments into the dialogue groups
        elsif ctx.last and ast.kind == :comment
          ctx.last.children << ast
          return true
        end
        false
      end
    end

    # Groups dialogues together into a dialogue_group
    class DialogueGrouper < BaseListGrouper
      def initialize
        super :dialogue, :dialogue_group
      end
    end

    # Joins multiple :p nodes together to get rid excess paragraph nodes,
    # loose :string nodes will be merged as well.
    class ParagraphGrouper < Grouper
      # (see Grouper#flush)
      def flush(ctx)
        return unless ctx.last
        ctx.last.value = ctx.last.value.strip
        ctx.last = nil
      end

      # (see Grouper#handle_ast)
      def handle_ast(ctx, ast)
        if ast.kind == :p || ast.kind == :string
          ctx.last ||= begin
            AST.new(:p, value: '', pos: ast.pos).tap { |l| ctx.result << l }
          end
          v = ast.value
          v = v.dump if ast.kind == :string
          ctx.last.value = ctx.last.value + " " + v
          return true
        end
        false
      end
    end

    # Groups :ln nodes together to form :list nodes
    class ListItemGrouper < BaseListGrouper
      def initialize
        super :ln, :list
      end
    end

    # Creates a new grouper from the grouper class and calls invoke with the
    # provided asts.
    #
    # @param [Class<Grouper>] grouper
    # @param [Array<AST>] asts
    # @return [Array<AST>]
    def self.invoke_grouper(grouper, asts)
      grouper.new.invoke(asts)
    end

    # Merges words together to form paragraphs
    #
    # @param [Array<AST>] asts
    # @return [Array<AST>]
    def self.group_words(asts)
      invoke_grouper WordGrouper, asts
    end

    # Groups consecutive dialogues together in a :dialogue_group
    #
    # @param [Array<AST>] asts
    # @return [Array<AST>]
    def self.group_dialogues(asts)
      invoke_grouper DialogueGrouper, asts
    end

    # Joins consecutive paragraphs together
    #
    # @param [Array<AST>] asts
    # @return [Array<AST>]
    def self.group_paragraphs(asts)
      invoke_grouper ParagraphGrouper, asts
    end

    # Groups :ln nodes together to form :list nodes
    #
    # @param [Array<AST>] asts
    # @return [Array<AST>]
    def self.group_list_items(asts)
      invoke_grouper ListItemGrouper, asts
    end

    # Empty labels will be treated as splitter nodes
    #
    # @param [Array<AST>] asts
    # @return [Array<AST>]
    def self.replace_empty_labels(asts)
      asts.map do |node|
        result = case node.kind
        when :label
          node.value.blank? ? AST.new(:split, pos: node.pos) : node.dup
        else
          node.dup
        end
        result.children = replace_empty_labels result.children
        result
      end
    end

    # Merges block tags with the div that follows it to form a div with a key.
    #
    # @param [Array<AST>] asts
    # @return [Array<AST>]
    def self.merge_block_tags(asts)
      i = 0
      result = []
      while i < asts.size
        ast = asts[i]
        t = ast.dup
        if t.kind == :tag and t[:type] == 'block'
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
          t.children = merge_block_tags t.children
        end
        result << t
        i += 1
      end
      result
    end

    # Removes all :el nodes from the tree
    #
    # @param [Array<AST>] asts
    # @return [Array<AST>]
    def self.drop_empty_lines(asts)
      asts.each_with_object([]) do |node, result|
        next if node.kind == :el
        node = node.dup
        node.children = drop_empty_lines node.children
        result << node
      end
    end

    # Merges common nodes together to make the tree more managable.
    #
    # @param [Array<AST>] asts
    # @return [Array<AST>]
    def self.process_asts(asts)
      asts = group_words asts
      asts = group_paragraphs asts
      asts = drop_empty_lines asts
      asts = group_dialogues asts
      asts = group_list_items asts
      asts = replace_empty_labels asts
      asts = merge_block_tags asts
      asts
    end

    # Sprinkles magic dust on the ast making it easier to use.
    #
    # @param [AST] ast  the root ast
    # @return [AST] processed root
    def self.process(ast)
      ast.dup.tap do |a|
        a.children = process_asts a.children
      end
    end
  end
end
