module Enumerable
  def select_by_class(klass)
    select { |obj| obj.class == klass }
  end
end
