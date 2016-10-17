# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-easyfb/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-easyfb"
  spec.version       = RailsAssetsAngularEasyfb::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Super easy AngularJS + Facebook JavaScript SDK."
  spec.summary       = "Super easy AngularJS + Facebook JavaScript SDK."
  spec.homepage      = "https://github.com/pc035860/angular-easyfb"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
