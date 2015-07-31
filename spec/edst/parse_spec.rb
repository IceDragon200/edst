require 'spec_helper'
require 'edst/parser'

describe EDST do
  context '#parse' do
    it 'should parse a basic edst file' do
      fn = File.expand_path('../../sample/edstspec.edst', File.dirname(__FILE__))
      res = EDST.parse(File.read(fn))
      expect(res).to be_instance_of EDST::AST
    end

    it 'should parse a complex edst file' do
      fn = File.expand_path('../../sample/complex.edst', File.dirname(__FILE__))
      res = EDST.parse(File.read(fn))
      expect(res).to be_instance_of EDST::AST
    end
  end
end
