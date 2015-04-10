require 'strscan'
require 'edst/parser'

describe EDST::Parsers::StringParser do
  it 'should scan a double quoted string' do
    ptr = StringScanner.new('"I am a String" and this is something that isnt')
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.value).to eq('I am a String')
    expect(res[:type]).to eq('double')
  end

  it 'should scan a single quoted string' do
    ptr = StringScanner.new('\'I am a String\' and this is something that isnt')
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.value).to eq('I am a String')
    expect(res[:type]).to eq('single')
  end

  it 'should scan a backtick quoted string' do
    ptr = StringScanner.new('`I am a String` and this is something that isnt')
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.value).to eq('I am a String')
    expect(res[:type]).to eq('backtick')
  end
end
