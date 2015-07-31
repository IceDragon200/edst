require 'spec_helper'
require 'edst/ast'

describe EDST::AST do
  subject(:sample_ast) { EDST.parse(File.read(fixture_pathname('test.edst'))) }

  context '#add_child' do
    it 'should add a new child' do
      ast = described_class.new(:root)
      child = described_class.new(:child)
      expect(ast.has_children?).to eq(false)
      ast.add_child(child)
      expect(ast.children).to include(child)
      expect(ast.has_children?).to eq(true)
    end
  end

  context '#has_children?' do
    it 'should have children' do
      expect(sample_ast.has_children?).to eq(true)
    end

    it 'a new AST should have no children' do
      expect(described_class.new(:test).has_children?).to eq(false)
    end
  end

  context '#to_h' do
    it 'should convert token to a Hash' do
      expect(subject.to_h).to be_instance_of(Hash)
    end
  end

  context '#search' do
    it 'should search a AST for nodes' do
      div = sample_ast.search('div').first
      expect(div).not_to be_nil
      expect(div.key).to eq('block')
      div_e = sample_ast.search('div.block div.block_e').first
      expect(div_e).not_to be_nil
      expect(div_e.key).to eq('block_e')
      tags = sample_ast.search('div.block tag').to_a
      expect(tags.size).to eq(4)
      non = sample_ast.search('div.block div.block_xyz').first
      expect(non).to eq(nil)
    end
  end

  context '#[]=' do
    it 'should set a attribute' do
      ast = described_class.new(:root)
      ast[:awesome] = 'eggo'
      expect(ast.attributes[:awesome]).to eq('eggo')
      expect(ast[:awesome]).to eq('eggo')
      expect(ast[:awesome]).to eq(ast.attributes[:awesome])
    end
  end
end
