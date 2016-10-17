# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-local-storage/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-local-storage"
  spec.version       = RailsAssetsAngularLocalStorage::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "An Angular module that gives you access to the browser's local storage"
  spec.summary       = "An Angular module that gives you access to the browser's local storage"
  spec.homepage      = "http://gregpike.net/demos/angular-local-storage/demo.html"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", ">= 1.0", "< 2"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
