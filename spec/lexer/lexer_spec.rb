require_relative '../spec_helper'
require 'edst/lexer'

describe EDST::Lexer do
  context '#tokenize' do
    it 'should tokenize a valid EDST stream' do
      data = File.read(File.join(File.dirname(__FILE__), '../../sample/edstspec.edst'))
      subject.lex(data)
    end
  end

  context '.lex' do
    it 'should tokenize a valid EDST stream' do
      data = File.read(File.join(File.dirname(__FILE__), '../../sample/edstspec.edst'))
      EDST::Lexer.lex(data)
    end
  end
end
