require_relative '../spec_helper'
require 'edst/parser/token'

describe EDST::Parser::Token do
  context '#to_h' do
    it 'should convert token to a Hash' do
      expect(subject.to_h).to be_instance_of(Hash)
    end
  end
end
