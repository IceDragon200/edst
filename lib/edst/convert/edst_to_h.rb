require 'edst/tokenize'
require 'tilt'

module EDST
  def self.edst_data_to_h(data, **options)
    read_token_map(data)
  end

  def self.edst_to_h(str, **options)
    edst_data_to_h(tokenize(str, options))
  end

  def self.edst_to_h_file(filename, **options)
    File.open filename, "r" do |file|
      return edst_to_h(file.read, verbose: false)
    end
  end
end
