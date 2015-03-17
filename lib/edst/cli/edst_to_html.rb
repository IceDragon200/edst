require 'rake/ext/string'
require 'edst/tokenize'
require 'edst/renderers/html'
require 'edst/context/chapter'
require 'active_support/core_ext'
require 'tilt'

module EDST
  def self.edst_to_html(data, inline)
    renderer = EDST::HTMLRenderer.new
    renderer.inline = inline
    token_data = EDST.tokenize data, verbose: false

    chapter = EDST::Context::Chapter.new
    chapter.setup token_data

    renderer.render chapter
  end

  def self.edst_to_html_file(filename, inline)
    out_filename = filename.ext('html')
    File.open filename, 'r' do |file|
      File.open out_filename, 'w' do |outfile|
        outfile.write edst_to_html(file, inline)
      end
    end
  end
end
