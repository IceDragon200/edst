require_relative 'spec_helper'
require 'edst/parser'

describe EDST do
  context '#to_h' do
    it 'should parse a valid edst file' do
      fn = File.expand_path('../../sample/edstspec.edst', File.dirname(__FILE__))
      res = EDST.parse(File.read(fn))
      expect(res).to be_instance_of EDST::AST
    end
  end
end