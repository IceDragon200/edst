class NullOut
  def self.puts(*args, &block)
    #
  end
end

def fixture_pathname(name)
  File.expand_path(File.join('../sample', name), File.dirname(__FILE__))
end

require 'edst'
