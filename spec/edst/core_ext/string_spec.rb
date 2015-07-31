require 'spec_helper'
require 'edst/core_ext/string'

describe String do
  subject(:demo_str) { "AAAAbbbbCCCCdedede" }

  context '#index_of_prev_closest' do
    it 'should return the index of the previous closest match' do
      expect(demo_str.index_of_prev_closest('d', 0)).to eq(-1)
      expect(demo_str.index_of_prev_closest('b', 8)).to eq(7)
    end
  end

  context '#index_of_next_closest' do
    it 'should return the index of the next closest match' do
      expect(demo_str.index_of_next_closest('d', 0)).to eq(12)
      expect(demo_str.index_of_next_closest('b', 8)).to eq(-1)
    end
  end
end
