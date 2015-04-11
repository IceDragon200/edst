require_relative '../spec_helper'
require 'strscan'
require 'edst/parser'
require 'yaml'

describe EDST::Parsers::StreamParser do
  it 'should parse a stream' do
    content = <<__EOF__
~EDST
%%edst
{
  %%head
  {
    %character ThatGuy
  }

  %%body
  {
    @ ThatGuy "Sometimes I wonder, which is worst, peanut butter on fish, or fish butter."

    Well this is the body, I hope the parser doesn't spaz out.
  }
}
__EOF__

    ptr = StringScanner.new(content)
    res = subject.match(ptr)
    expect(res).to be_instance_of(EDST::AST)
    expect(res.kind).to eq(:root)
    root_children = res.children
    # uncompressed, there should be 2 children, 1 tag and 1 div
    expect(root_children.size).to eq(3)
    edstdiv = root_children[2]
    expect(edstdiv.children.size).to eq(5)
    head = edstdiv.children[1]
    expect(head.children.size).to eq(1)
    body = edstdiv.children[4]
    # there are just so many words D:
    expect(body.children.size).to eq(14)
  end
end
