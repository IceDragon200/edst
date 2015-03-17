require 'edst/context/base'
require 'edst/convert/edst_to_h'

module EDST
  module Context
    class Index < Base
      attr_accessor :meta
      attr_accessor :chapters
      attr_accessor :clusters
      attr_accessor :navigation

      attr_reader :title
      attr_reader :sub_title
      attr_reader :book_number

      def initialize(options = {})
        super
        @meta = nil
        @chapters = nil
        @clusters = nil
        @navigation = nil
        @title = ''
        @sub_title = ''
        @book_number = '0'
      end

      def display_title
        '%s : %s' % [@title, @sub_title]
      end

      def page_title
        '%s : %s Index' % [@title, @sub_title]
      end

      def setup(tokens, **options)
        data = EDST.edst_data_to_h(tokens)
        if book_data = data['book']
          @title = book_data['title']
          @sub_title = book_data['sub_title']
          @book_number = book_data['number']
        end
      end

      def content_template_name
        case @layout_mode
        when :html
          'views/index.html.slim'
        when :text
          'views/index.txt.erb'
        end
      end
    end
  end
end
