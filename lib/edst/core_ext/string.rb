class String
  def word_count
    scan(/\S+/).size
  end

  def words
    scan(/['\w]+/)
  end

  def heading_whitespace
    gsub!(/^(\s+)\w/) { return $1 }
    false
  end

  def uncomment!
    gsub!(/\s*#/, '')
  end

  def uncomment
    dup.tap { |s| s.uncomment! }
  end
end
