require 'edst/renderers/html'
require 'edst/renderers/text'

module EDST
  module Context
    class Base
      include EDST::HTMLRenderer
      include EDST::TextRenderer

      attr_accessor :layout_mode

      def initialize(options = {})
        @layout_mode = options.fetch(:layout_mode, :html)
        init_renderer(options)
      end

      def content_template_name
      end

      def edst_escape(str)
        case @layout_mode
        when :html
          edst_escape_html(str)
        when :text
          edst_escape_text(str)
        end
      end

      def render_content(*args, &block)
        partial(content_template_name, *args, &block)
      end

      def layout_template
        case @layout_mode
        when :html
          'views/layout.html.slim'
        when :text
          'views/layout.txt.erb'
        end
      end

      def render
        partial(layout_template) { render_content }
      end
    end
  end
end
