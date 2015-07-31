module EDST
  # Logging interface for the Renderer
  class Alert
    # @param [Object] args
    # @return [void]
    def fixme(*args)
      puts "FIXME: #{args.join(' ')}".colorize(:light_yellow)
    end
  end
end
