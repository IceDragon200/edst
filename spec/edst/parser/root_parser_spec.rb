require 'spec_helper'
require 'strscan'
require 'edst/parser'

describe EDST::Parsers::RootParser do
  subject(:parser) { EDST::Parsers::RootParser.new }
  subject(:vparser) { EDST::Parsers::RootParser.new(verbose: true, logger: NullOut) }

  it 'should parse a block' do
    ptr = StringScanner.new("{\n%tag thingy\n}")
    res = parser.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.kind).to eq(:div)
    expect(res.children[0].kind).to eq(:tag)
  end

  it 'should jam with an invalid block' do
    ptr = StringScanner.new("{\n{\n%tag thingy\n}\n")
    expect { parser.match(ptr) }.to raise_error EDST::ParserJam
    ptr.pos = 0
    expect { vparser.match(ptr) }.to raise_error EDST::ParserJam
  end
end
