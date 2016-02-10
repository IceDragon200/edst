require 'ostruct'

class OpenStruct
  # For merging any object that responds to each_pair into the given OpenStruct
  #
  # @param [OpenStruct] c  target
  # @param [Array<#each_pair>] args
  # @return [OpenStruct]
  def self.conj!(c, *args)
    args.each do |b|
      b.each_pair do |k, v|
        c[k] = v
      end
    end
    c
  end

  # For merging any object that responds to each_pair into a new OpenStruct
  #
  # @param [Array<#each_pair>] args
  # @return [OpenStruct]
  def self.conj(*args)
    conj!(new, *args)
  end
end
