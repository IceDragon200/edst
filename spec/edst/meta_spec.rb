require_relative 'spec_helper'
require 'edst/meta'

describe EDST::Meta do
  it 'should convert book.edst to data' do
    filename = File.expand_path('../sample/book.edst', File.dirname(__FILE__))
    EDST::Meta.generate_from_file(filename)
  end
end
