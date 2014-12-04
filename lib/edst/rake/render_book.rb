require 'rake'
require 'rake/task'
require 'rake/clean'
require 'rake/tasklib'
require 'edst/tokenize'
require 'edst/context/chapter'
require 'edst/context/index'
require 'active_support/core_ext'
require 'tilt'
require 'yajl'
require 'ostruct'

module EDST
  module RakeTasks
    class Book < Rake::TaskLib
      attr_reader :template_manager
      attr_accessor :destpath
      attr_accessor :srcpath
      attr_accessor :src_name
      attr_accessor :navigation_filename
      attr_accessor :book_filename
      attr_accessor :meta_filename
      attr_accessor :chapters_glob_filename
      attr_accessor :chapter_frags_glob_filename
      attr_accessor :files
      attr_accessor :navigation
      attr_accessor :meta
      attr_accessor :chapters
      attr_accessor :chapters_by_filename

      def initialize(src, dest)
        @srcpath = src
        @destpath = dest
        @meta = nil
        @navigation = nil
        @chapters_by_filename = {}
        @chapters = {}
        @navigation_filename = File.expand_path('chapter/navigate.json', @srcpath)
        @book_filename = File.expand_path('book.edst', @srcpath)
        @meta_filename = File.expand_path('meta.json', @srcpath)
        @chapters_glob_filename = File.expand_path('chapter/ch*.edst', @srcpath)
        @chapter_frags_glob_filename = File.expand_path('chapter/frags/*.edst', @srcpath)
        @template_manager = EDST::TemplateManager.new(paths: [File.expand_path('templates', @destpath)])

        @files = FileList[@chapters_glob_filename] + FileList[@chapter_frags_glob_filename]
        if File.exist?(@navigation_filename)
          File.open(@navigation_filename, 'r') do |f|
            @navigation = Yajl::Parser.parse(f).map do |k, v|
              [k.to_i, v]
            end.to_h
          end
        else
          @navigation = nil
          warn "WARN: #{@navigation_filename.dump} does not exist"
        end

        if File.exist?(@meta_filename)
          File.open(@meta_filename, 'r') do |f|
            @meta = Yajl::Parser.parse(f)
          end
        end

        @files.each do |filename|
          File.open filename, 'r' do |file|
            token_data = EDST.tokenize file, verbose: false

            chapter = EDST::Context::Chapter.new(template_manager: @template_manager)
            chapter.meta = @meta
            chapter.navigation = @navigation
            chapter.chapters = @chapters
            chapter.setup token_data

            @chapters_by_filename[filename] = @chapters[chapter.chapter_id] = chapter
          end
        end

        yield self if block_given?

        define
      end

      def define_index
        task :build_index do
          book = File.read(@book_filename)

          filename = File.expand_path('index.html', @destpath)

          index = EDST::Context::Index.new(template_manager: @template_manager)
          index.meta = @meta
          index.chapters = @chapters
          index.navigation = @navigation

          token_data = EDST.tokenize(book)

          index.setup token_data

          File.open filename, 'w' do |file|
            file.write index.render
          end
        end
        task index: :build_index
      end

      def define_stylesheets
        #source = @template_manager.find_file('stylesheets/main.scss')
        #source_dirname = File.dirname(source)
        #sources = FileList["#{File.join(source_dirname, '**/*.scss')}"]
        #dest = File.expand_path('css/main.css', @destpath)
        #file dest => sources do
        #  Sass.compile_file(source, dest)
        #end
        dest = File.expand_path('css/main.css', @destpath)
        task :stylesheets do
          File.write(dest, @template_manager.render_template('stylesheets/main.scss'))
        end
      end

      def define_html
        task :html do
          @files.each do |filename|
            out_filename = File.expand_path(File.basename(filename.ext('.html')), @destpath)

            chapter = @chapters_by_filename[filename]

            if chapter
              c = chapter.dup
              c.layout_mode = :html
              File.write out_filename, c.render
            else
              warn "WARN: [#{src_name}] Chapter #{filename} is missing"
            end
          end
        end
      end

      def define_text
        task :text do
          @files.each do |filename|
            out_filename = File.expand_path(File.basename(filename.ext('.txt')), @destpath)

            chapter = @chapters_by_filename[filename]

            if chapter
              c = chapter.dup
              c.layout_mode = :text
              File.write out_filename, c.render
            else
              warn "WARN: [#{src_name}] Chapter #{filename} is missing"
            end
          end
        end
      end

      def define_build
        task build: [:stylesheets, :text, :html, :index]
      end

      protected def define
        define_index
        define_stylesheets
        define_html
        define_text
        define_build
      end
    end
  end
end
