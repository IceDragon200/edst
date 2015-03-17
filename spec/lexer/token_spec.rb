require_relative '../spec_helper'
require 'edst/lexer/token'

describe EDST::Lexer::Token do
  context '#to_h' do
    it 'should convert token to a Hash' do
      expect(subject.to_h).to be_instance_of(Hash)
    end
  end
end
