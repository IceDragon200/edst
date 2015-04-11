module EDST
  module Version
    MAJOR, MINOR, TEENY, PATCH = 0, 24, 0, nil
    STRING = [MAJOR, MINOR, TEENY, PATCH].compact.join('.').freeze
  end
  VERSION = Version::STRING
end
