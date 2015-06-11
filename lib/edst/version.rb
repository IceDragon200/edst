module EDST
  # Le Version module, what more do you need to know.
  module Version
    MAJOR, MINOR, TEENY, PATCH = 0, 27, 0, nil
    STRING = [MAJOR, MINOR, TEENY, PATCH].compact.join('.').freeze
  end
  VERSION = Version::STRING
end
