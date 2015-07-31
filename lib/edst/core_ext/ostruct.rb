class OpenStruct
  def self.conj(a, b)
    new(a).tap do |c|
      b.each_pair do |k, v|
        c[k] = v
      end
    end
  end
end
