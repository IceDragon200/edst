class NullOut
  def self.puts(*args, &block)
    #
  end
end

def fixture_pathname(name)
  File.expand_path(File.join('../sample', name), File.dirname(__FILE__))
end

require 'codeclimate-test-reporter'
require 'simplecov'

CodeClimate::TestReporter.start
SimpleCov.start

require 'edst'
