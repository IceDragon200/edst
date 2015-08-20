require 'tilt'

module EDST
  # A simple class for finding, loading and using tilt templates on the
  # file system.
  class TemplateManager
    # @return [String] The default location to look for templates from
    ROOT_PATH = File.dirname(__FILE__)

    # @return [Array<String, Tilt>]
    @@glob_templates = {}

    # @!attribute paths
    #   @return [Array<String>] paths to look for templates in
    attr_accessor :paths
    # @!attribute logger
    #   @return [#puts] debug logger
    attr_accessor :logger

    # @param [Hash<Symbol, Object>] options
    def initialize(**options)
      @templates = {}
      user_paths = options.fetch(:paths, [])
      @paths = []
      @paths += user_paths
      @paths << ENV['EDST_TEMPLATE_PATH']
      @paths << File.expand_path('templates', root_path)
      @paths.compact!
      @logger = nil
    end

    # Yields the internal logger if it exists.
    #
    # @yieldparam [#puts] logger
    # @return [void]
    def debug_log
      yield @logger if @logger
    end

    # The directory where the template_manager is located.
    #
    # @return [String]
    # @api
    def root_path
      ROOT_PATH
    end

    # @param [String] name  name to glob
    # @return [Array<String>]
    def glob(name)
      @paths.each_with_object([]) do |dirname, a|
        path = File.expand_path(name, dirname)
        a.concat(Dir.glob(path))
      end
    end

    # Tries to find a template with the given name, if not template was found
    # nil is returned, else the full path to the template is returned.
    #
    # @param [String] name
    # @return [String, nil]
    def find_file(name)
      @paths.each do |dirname|
        path = File.expand_path(name, dirname)
        return path if File.exist?(path)
      end
      fail "template: #{name} could not be found in paths"
    end

    # Loads a template using tilt, or returns an existing one from the
    # template cache.
    #
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

    # Loads and renders a template, the extra args depend on the template.
    #
    # @param [String] name
    # @param [Object] args
    # @return [String] rendered result
    def render_template(name, *args, &block)
      load_template(name).render(*args, &block)
    end
  end
end
