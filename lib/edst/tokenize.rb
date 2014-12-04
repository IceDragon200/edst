require 'active_support/core_ext'
require 'edst/core_ext/string'
require 'edst/parser/token'
require 'edst/parser'
require 'yajl'

module EDST
  def self.compress_elements(tokens, **options)
    last_p = nil
    last_ln = nil
    result = []
    tokens.each do |basetoken|
      if basetoken.kind == :p
        if last_p
          last_p.value = last_p.value + " " + basetoken.value
        else
          last_p = basetoken.dup
          result << last_p
        end
      elsif basetoken.kind == :ln
        if last_ln
          last_ln.children << basetoken
        else
          last_ln = EDST::Parser::Token.new(:list, children: [basetoken])
          result << last_ln
        end
      else
        last_ln = nil
        last_p = nil
        token = basetoken.dup
        token.children = compress_elements(token.children, options)
        result << token
      end
    end
    result
  end

  ###
  # @param [Object] obj
  # @param [Hash] options
  def self.tokenize(obj, **options)
    rawtokens = Parser.parse(obj, options)
    tokens = compress_elements(rawtokens)
    Yajl::Parser.parse(Yajl::Encoder.encode(tokens.map(&:to_token_a)))
  end

  ###
  # @param [String] filename
  # @param [Hash] options
  # @return [Array<Tuple<Symbol, Hash>>]
  def self.tokenize_file(filename, options={})
    File.open filename, 'r' do |file|
      return tokenize file, options
    end
  end

  ###
  # Converts tokens to a "Name Value Pair" Hash
  # @param [Array<Tuple<Symbol, Hash>>] tokens
  def self.tokens_to_nvp(tokens)
    sub_search = lambda do |data, **opts|
      result = {}
      last_key = ''
      data.each do |key, content|
        if key == 'div'
          (result[last_key] ||=[]).push(sub_search.(content['content'], block_key: last_key))
        elsif key == 'tag' && content['type'] == 'block'
          last_key = content['key']
        elsif key == 'tag'
          (result[content['key']] ||=[]).push(content['value'])
          last_key = nil
        elsif key == 'label'
          (result['parts']||=[]) << content['value'] if opts[:block_key] == 'parts'
        else
          last_key = nil
        end
      end
      result
    end
    return sub_search.(tokens)
  end

  def self.read_token_map(tokens, depth = 0)
    sub_count = 0
    same_key_count = {}
    same_key_count.default = 0

    result = {}
    next_is_content = nil
    tokens.each do |(token_type, data)|
      case token_type
      when 'div'
        if next_is_content
          keyname = next_is_content
          next_is_content = nil
        else
          sub_count += 1
          keyname = "anonymous.#{depth}.#{sub_count}"
        end
        count = same_key_count[keyname] += 1
        keyname = "#{keyname}.#{count}" if count > 1
        result[keyname] = read_token_map data['children'], depth + 1
      when 'tag'
        if data['attributes']['type'] == 'block'
          next_is_content = data['key']
        else
          keyname = data['key']
          count = same_key_count[keyname] += 1
          keyname = "#{keyname}#{count}" if count > 1
          result[keyname] = data['value']
        end
      when 'p'
        (result['&content'] ||= '').concat(data['value'])
      end
    end

    result
  end
end
