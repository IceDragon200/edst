require_relative '../spec_helper'
require "edst/parser"

describe EDST::Parser do
  context '#tokenize' do
    it 'should tokenize a valid EDST stream' do
      data = File.read(File.join(File.dirname(__FILE__), '../../sample/edstspec.edst'))
      subject.tokenize(data)
    end
  end

  context '.parse' do
    it 'should tokenize a valid EDST stream' do
      data = File.read(File.join(File.dirname(__FILE__), '../../sample/edstspec.edst'))
      EDST::Parser.parse(data)
    end
  end
end
