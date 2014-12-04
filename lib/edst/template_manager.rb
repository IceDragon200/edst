require 'active_support/core_ext'
require 'tilt'

module EDST
  class TemplateManager
    # @return [String]
    ROOT_PATH = File.dirname(__FILE__)

    # @return [Array<String, Tilt>]
    @@glob_templates = {}

    # @return [Array<String>]
    attr_accessor :paths
    attr_accessor :log

    # @param [Hash<Symbol, Object>] options
    def initialize(**options)
      @templates = {}
      user_paths = options.fetch(:paths, [])
      @paths = []
      @paths += user_paths
      @paths << ENV['EDST_TEMPLATE_PATH']
      @paths << File.expand_path('templates', root_path)
      @paths.compact!
      @log = nil
    end

    def debug_log
      yield @log if @log
    end

    # @return [String]
    def root_path
      ROOT_PATH
    end

    # @param [String]
    # @return [String]
    def find_file(name)
      @paths.each do |dirname|
        path = File.expand_path(name, dirname)
        return path if File.exist?(path)
      end
      fail "template: #{name} could not be found in paths"
      return nil
    end

    # @param [String] name
    # @return [Tilt] template
    def load_template(name)
      @templates[name] ||= begin
        filename = find_file(name)
        debug_log { |io| io.puts("using template: #{filename.inspect}") }
        @@glob_templates[filename] ||= begin
          Tilt.new(filename)
        end
      end
    end

    # @param [String] name
    def render_template(name, *args, &block)
      load_template(name).render(*args, &block)
    end
  end

  module Partials
    # @return [EDST::TemplateManager]
    attr_accessor :template_manager

    # @param [String] name
    def partial(name, *args, &block)
      @template_manager.render_template(name, self, *args, &block)
    end
  end
end
