require 'slim'
require 'edst/renderers/base_renderer'

module EDST
  # EDST's generic HTML renderer
  class QuickHtmlRenderer < BaseRenderer
    def initialize
      super template_name: 'views/generic.html.slim'
    end

    register 'html'
  end
end
