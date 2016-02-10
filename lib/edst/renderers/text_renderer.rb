require 'erubis'
require 'edst/renderers/base_renderer'

module EDST
  # EDST's generic HTML renderer
  class TextRenderer < BaseRenderer
    def initialize
      super template_name: 'views/text.txt.erb'
    end

    register 'txt', 'text'
  end
end
