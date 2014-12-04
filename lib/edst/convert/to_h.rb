require 'edst/parser'

module EDST
  def self.tokens_to_h(tokens)
    tokens.map(&:to_h)
  end
end
