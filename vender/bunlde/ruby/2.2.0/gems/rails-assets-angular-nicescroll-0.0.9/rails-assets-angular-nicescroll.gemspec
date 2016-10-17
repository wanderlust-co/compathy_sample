# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-nicescroll/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-nicescroll"
  spec.version       = RailsAssetsAngularNicescroll::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Angular Nicescroll Directive"
  spec.summary       = "Angular Nicescroll Directive"
  spec.homepage      = "http://tushariscoolster.github.io/angular-nicescroll"
  spec.license       = "LGPL-2.1"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-jquery.nicescroll", ">= 0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
