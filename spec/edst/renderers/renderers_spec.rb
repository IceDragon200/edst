require 'spec_helper'
require 'edst/renderers'
require 'tempfile'
require 'tmpdir'

# TODO: probably check the output

shared_examples_for "a renderer" do
  context '#render_stream_to' do
    it 'renders a String stream to a String' do
      dest = ''
      src = File.read(fixture_pathname('edstspec.edst'))
      subject.render_stream_to src, dest
    end

    it 'renders a File stream to a String' do
      dest = ''
      File.open(fixture_pathname('edstspec.edst'), 'r') do |src|
        subject.render_stream_to src, dest
      end
    end

    it 'renders a File stream to a File' do
      tmp = Tempfile.new('edst-testfile.edst')
      File.open(tmp.path, 'w') do |dest|
        File.open(fixture_pathname('edstspec.edst'), 'r') do |src|
          subject.render_stream_to src, dest
        end
      end
    end
  end

  context '#render_file' do
    it 'renders a file to another file' do
      Dir.mktmpdir('edst-testdir') do |dir|
        subject.render_file fixture_pathname('edstspec.edst'), directory: dir
      end
    end
  end
end

describe EDST::TextRenderer do
  it_behaves_like 'a renderer'
end

describe EDST::QuickHtmlRenderer do
  it_behaves_like 'a renderer'
end

describe EDST::MarkdownRenderer do
  it_behaves_like 'a renderer'
end
