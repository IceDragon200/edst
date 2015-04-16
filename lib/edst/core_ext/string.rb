class String
  # Finds the index of the closest thing that matches the provided query.
  #
  # @param [Integer] d  direction (1, or -1)
  # @param [String, Regexp] q  query
  # @param [Integer] from  starting position
  def index_of_closest(d, q, from = 0)
    s = from
    until q === str[s]
      break s = 0 if s <= 0
      s += d
    end
    s -= d if q === str[s]
    s
  end

  # Finds the previous closest thing that matches the query.
  #
  # @param [String, Regexp] q  query
  # @param [Integer] from  starting position
  def index_of_prev_closest(q, from = 0)
    index_of_closest -1, q, from
  end

  # Finds the next closest thing that matches the query.
  #
  # @param [String, Regexp] q  query
  # @param [Integer] from  starting position
  def index_of_next_closest(q, from = 0)
    index_of_closest 1, q, from
  end
end
