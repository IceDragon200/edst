require_relative '../spec_helper'
require 'strscan'
require 'edst/parser'

describe EDST::Parsers::LineItemParser do
  it 'should parse a line item' do
    ptr = StringScanner.new('--- this is an item')
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.kind).to eq(:ln)
    expect(res.value).to eq('this is an item')
  end
end
