require 'strscan'
require 'edst/parser'

describe EDST::Parsers::TagParser do
  it 'should parse a 1 line tag' do
    ptr = StringScanner.new('%tag I am a Tag')
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.key).to eq('tag')
    expect(res.value).to eq('I am a Tag')
  end

  it 'should parse a long key tag' do
    ptr = StringScanner.new('%%I am the tag key')
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.key).to eq('I am the tag key')
    expect(res.value).to eq(nil)
  end
end
