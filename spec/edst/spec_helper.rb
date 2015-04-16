class NullOut
  def self.puts(*args, &block)
    #
  end
end

require 'codeclimate-test-reporter'
require 'simplecov'

CodeClimate::TestReporter.start
SimpleCov.start


require 'edst'
