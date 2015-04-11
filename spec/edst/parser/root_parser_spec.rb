require_relative '../spec_helper'
require 'strscan'
require 'edst/parser'

describe EDST::Parsers::RootParser do
  subject(:parser) { EDST::Parsers::RootParser.new }

  it 'should parse a block' do
    ptr = StringScanner.new("{\n%tag thingy\n}")
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.kind).to eq(:div)
    expect(res.children[0].kind).to eq(:tag)
  end
end
