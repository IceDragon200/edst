require 'slim'
require 'edst/cli/base_renderer'

module EDST
  # EDST's generic HTML renderer
  class QuickHtmlRenderer < BaseRenderer
    # @return [String]
    def default_template_name
      'views/generic.html.slim'
    end

    register 'html'
  end
end
