require 'erubis'
require 'edst/cli/base_renderer'

module EDST
  # Markdown renderer
  class MarkdownRenderer < BaseRenderer
    # @return [String]
    def default_template_name
      'views/markdown.md.erb'
    end

    register 'md', 'markdown'
  end
end
