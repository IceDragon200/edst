require 'spec_helper'
require 'strscan'
require 'edst/parser'

describe EDST::Parsers::HeaderParser do
  it 'should parse a header' do
    ptr = StringScanner.new('~IM:A:HEADER')
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.kind).to eq(:header)
    expect(res.value).to eq('IM:A:HEADER')
  end

  it 'should fail to parse a header without words' do
    ptr = StringScanner.new('~')
    expect { subject.match(ptr) }.to raise_error(EDST::InvalidHeader)
  end
end
