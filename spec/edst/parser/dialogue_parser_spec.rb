require 'strscan'
require 'edst/parser'

describe EDST::Parsers::DialogueParser do
  it 'should parse a dialogue' do
    ptr = StringScanner.new('@ Speaker "Yeah :3, this here is the greatest thing EVER."')
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.key).to eq('Speaker')
    expect(res.value).to eq('Yeah :3, this here is the greatest thing EVER.')
  end
end
