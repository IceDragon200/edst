require_relative '../spec_helper'
require 'edst/core_ext/string'

describe String do
  context '#word_count' do
    it 'should count number of words in String' do
      expect('These are words'.word_count).to eq(3)
    end
  end

  context '#words' do
    it 'should convert String to Array of words' do
      'words are for turds'.words
    end
  end
end
