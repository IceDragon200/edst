require_relative '../spec_helper'
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

  it 'should fail if the dialogue text is missing' do
    ptr = StringScanner.new('@ ThatGuy')
    expect { subject.match(ptr) }.to raise_error(described_class::DialogueTextMissing)
  end
end
