# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-google-maps/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-google-maps"
  spec.version       = RailsAssetsAngularGoogleMaps::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = ""
  spec.summary       = ""
  spec.homepage      = "https://github.com/angular-ui/angular-google-maps"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", ">= 1.2", "< 1.5"
  spec.add_dependency "rails-assets-angular-simple-logger", "~> 0.0.1"
  spec.add_dependency "rails-assets-lodash", ">= 3.8.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
