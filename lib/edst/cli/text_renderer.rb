require 'slim'
require 'edst/cli/base_renderer'

module EDST
  # EDST's generic HTML renderer
  class TextRenderer < BaseRenderer
    # @return [String]
    def default_template_name
      'views/text.txt.erb'
    end

    register 'txt', 'text'
  end
end
