require 'spec_helper'
require 'strscan'
require 'edst/parser'

describe EDST::Parsers::LabelParser do
  it 'should parse a label' do
    ptr = StringScanner.new('-- this is a label --')
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.kind).to eq(:label)
    expect(res.value).to eq('this is a label')
  end
end
