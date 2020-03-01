module EDST
  module Util
    def is_blank?(object)
      case object
      when nil, ""
        true
      when String
        object.empty? || object.strip.empty?
      when Array, Hash
        object.empty?
      else
        false
      end
    end

    def is_present?(object)
      not is_blank?(object)
    end

    def presence(object)
      if is_present?(object)
        object
      else
        nil
      end
    end

    def underscore(str)
      str.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

    # Removes excess spaces, newlines and tabs from the string.
    #
    # @return [String]
    def deflate(str)
      str.gsub("\n", ' ').gsub(/(\s+|\t+)/, ' ')
    end

    # https://github.com/samsouder/titlecase/blob/master/lib/titlecase.rb
    def titlecase(str)
      small_words = %w(a an and as at but by en for if in of on or the to v v. via vs vs.)

      x = str.split(" ").map do |word|
        # note: word could contain non-word characters!
        # downcase all small_words, capitalize the rest
        small_words.include?(word.gsub(/\W/, "").downcase) ? word.downcase! : smart_capitalize(word)
        word
      end
      # capitalize first and last words
      x[0] = smart_capitalize(x[0].to_s)
      x[-1] = smart_capitalize(x[-1].to_s)
      # small words after colons are capitalized
      x.join(" ").gsub(/:\s?(\W*#{small_words.join("|")}\W*)\s/) { ": #{smart_capitalize($1)} " }
    end

    def smart_capitalize(str)
      # ignore any leading crazy characters and capitalize the first real character
      if str =~ /^['"\(\[']*([a-z])/
        i = str.index($1)
        x = str[i,str.size]
        # word with capitals and periods mid-word are left alone
        str[i,1] = str[i,1].upcase unless x =~ /[A-Z]/ or x =~ /\.\w+/
      end
      str
    end

    extend self
  end
end
