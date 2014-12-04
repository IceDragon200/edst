class Object
  def to_toml
    TOML.dump(self)
  end
end
