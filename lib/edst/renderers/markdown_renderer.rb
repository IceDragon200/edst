require 'erubis'
require 'edst/renderers/base_renderer'

module EDST
  # Markdown renderer
  class MarkdownRenderer < BaseRenderer
    def initialize
      super template_name: 'views/markdown.md.erb'
    end

    register 'md', 'markdown'
  end
end
