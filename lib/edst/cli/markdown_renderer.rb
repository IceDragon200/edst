require 'active_support/core_ext/string'
require 'active_support/core_ext/object/blank'
require 'edst/parser'
require 'edst/template_manager'
require 'edst/partials'
require 'edst/cli/common'
require 'erubis'

module EDST
  class MarkdownRenderer
    def render_file(filename, options = {})
      tm = TemplateManager.new
      tm.paths.unshift Dir.getwd
      tm.paths.unshift options.directory

      parser_options = options.parser_options || {}

      root = EDST.parse File.read(filename), parser_options
      root.children.unshift EDST::AST.new(:comment, value: filename)

      ctx = Context.new
      ctx.filename = filename
      ctx.tree = root
      ctx.template_manager = tm
      ctx.asset_exports = [] # files that need to be copied as well

      result = tm.render_template(options.template || 'views/markdown.md.erb', ctx)
      basename = File.basename(filename, File.extname(filename))
      out = File.join(options.directory, "#{basename}.md")

      puts "\tRENDER #{out}".colorize(:light_green)
      File.write(out, result)

      dirname = File.dirname(filename)
      ctx.asset_exports.each do |pair|
        src, dest = *pair
        s = File.expand_path(src, dirname)
        d = File.expand_path(dest, options.directory)
        if File.exist?(d)
          puts "\tASSET #{d}".colorize(:light_blue)
        elsif !File.exist?(s)
          puts "\tMISSING ASSET #{s}".colorize(:light_red)
        else
          FileUtils.mkdir_p File.dirname(d)
          FileUtils.cp s, d
          puts "\tNEW ASSET #{d}".colorize(:light_green)
        end
      end
    end
  end
end
