require 'spec_helper'
require 'strscan'
require 'edst/parser'

describe EDST::Parsers::CommentParser do
  it 'should parse a comment' do
    ptr = StringScanner.new('# hi, Im a comment')
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.kind).to eq(:comment)
    expect(res.value).to eq(' hi, Im a comment')
  end
end
