#
# edst/edst.gemspec
#
require_relative 'lib/edst/version'
require 'date'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'edst'
  s.summary     = 'EDST Markup Language toolkit'
  s.description = 'All you need to read and write .edst files'
  s.date        = Time.now.to_date.to_s
  s.version     = EDST::Version::STRING
  s.homepage    = 'https://github.com/IceDragon200/edst/'
  s.license     = 'MIT'

  s.authors = ['Corey Powell']
  s.email  = 'mistdragon100@gmail.com'

  s.add_runtime_dependency 'colorize',      '~> 0.7'
  s.add_runtime_dependency 'rake',          '~> 10.3'
  s.add_runtime_dependency 'toml-rb',       '~> 0.1'
  s.add_runtime_dependency 'bson',          '~> 2.3'
  s.add_runtime_dependency 'tilt',          '~> 2.0'
  s.add_runtime_dependency 'erubis',        '~> 2.7'
  s.add_runtime_dependency 'sass',          '~> 3.4'
  s.add_runtime_dependency 'activesupport', '>= 4.2', '< 6.0'
  s.add_runtime_dependency 'yajl-ruby',     '~> 1.2'
  # dev
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'rspec',     '~> 3.1'

  s.require_path = 'lib'
  s.executables = Dir.glob('bin/*').map { |s| File.basename(s) }
  s.files = ['Gemfile']
  s.files.concat(Dir.glob('{bin,lib,spec}/**/*'))
end
