# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smart_table/version'

Gem::Specification.new do |spec|
  spec.name          = "smart_table"
  spec.version       = SmartTable::VERSION
  spec.authors       = ["Henrique Gubert"]
  spec.email         = ["guberthenrique@hotmail.com"]

  spec.summary       = %q{Implements tables with pagination and search for Rails,
    with server-side content loading.}
  spec.description   = %q{}

  spec.files         = Dir[File.dirname(__FILE__) + '/**/*'].reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # this gem should be used in a rails app
  spec.add_runtime_dependency 'rails', '<5.3.0', '>4.2.0'
  spec.add_runtime_dependency 'kaminari'
  spec.add_runtime_dependency 'font-awesome-rails'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rspec-rails', '~> 3.7'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency "byebug", '~> 9'
end
