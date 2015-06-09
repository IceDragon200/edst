class String
  # Removes excess spaces, newlines and tabs from the string.
  #
  # @return [String]
  def deflate
    gsub("\n", ' ').gsub(/(\s+|\t+)/, ' ')
  end
end
