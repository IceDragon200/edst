require 'active_support/core_ext/string'
require 'active_support/core_ext/object/blank'
require 'edst'
require 'edst/lexer'
require 'edst/template_manager'
require 'pp'
require 'slim'
require 'tilt'
require 'ostruct'
require 'fileutils'
require 'colorize'

module EDST
  class QuickHtmlRenderer
    def merge_tokens(tokens)
      i = 0
      result = []
      last_list = nil
      last_p = nil
      while i < tokens.size
        token = tokens[i]
        t = token.dup
        last_list = nil unless t.kind == :ln
        last_p = nil unless t.kind == :p
        case t.kind
        when :p
          if last_p
            last_p.value = last_p.value + " " + t.value
            t = nil
          else
            last_p = t.dup
            result << last_p
            t = nil
          end
        when :ln
          if last_list
            last_list.add_child t
            t = nil
          else
            last_list = EDST::Lexer::Token.new(:list, children: [t])
            result << last_list
            t = nil
          end
        when :label
          if t.value.blank?
            t.kind = :split
          end
        when :tag
          if t[:type] == 'block'
            i += 1
            oi = i
            until tokens[i].kind == :div
              fail unless i < tokens.size
              i += 1
            end
            tks = tokens[oi, i - oi]
            d = tokens[i]
            t.kind = :div
            t.children = t.children + tks + d.children
            t.attributes.delete(:type)
          end
        when :el
          t = nil
        end
        if t
          t.children = merge_tokens t.children
          result << t
        end
        i += 1
      end
      result
    end

    def render_file(filename, options)
      tm = TemplateManager.new
      tm.paths.unshift Dir.getwd
      tm.paths.unshift options.directory

      tokens = EDST::Lexer.lex File.read(filename)
      tokens = merge_tokens tokens
      tokens.unshift EDST::Lexer::Token.new(:comment, value: filename)

      ctx = OpenStruct.new
      ctx.filename = filename
      ctx.tree = EDST::Lexer::Token.new(:root, children: tokens)
      ctx.template_manager = tm
      ctx.asset_exports = [] # files that need to be copied as well

      result = tm.render_template(options.template || 'views/generic.html.slim', ctx)
      basename = File.basename(filename, File.extname(filename))
      out = File.join(options.directory, "#{basename}.html")

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

    def self.render_file(filename, options)
      new.render_file filename, options
    end
  end
end
