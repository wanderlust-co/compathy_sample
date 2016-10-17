# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-simple-logger/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-simple-logger"
  spec.version       = RailsAssetsAngularSimpleLogger::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Basic logger with level logging which can also be independent."
  spec.summary       = "Basic logger with level logging which can also be independent."
  spec.homepage      = "https://github.com/nmccready/angular-simple-logger"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", ">= 1.2", "< 2"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
