require 'erubis'
require 'edst/renderers/base_renderer'

module EDST
  # EDST's generic HTML renderer
  class QuickHtmlRenderer < BaseRenderer
    def initialize
      super template_name: 'views/generic.html.erb'
    end

    register 'html'
  end
end
