require_relative '../spec_helper'
require 'edst/core_ext/array'

describe Array do
  it 'should reverse sort' do
    a = [2, 9, 4]
    expect(a.reverse_sort).to eq([9, 4, 2])
  end
end
