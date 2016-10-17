# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angularjs-slider/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angularjs-slider"
  spec.version       = RailsAssetsAngularjsSlider::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "AngularJS slider directive with no external dependencies. Mobile friendly!"
  spec.summary       = "AngularJS slider directive with no external dependencies. Mobile friendly!"
  spec.homepage      = "https://github.com/angular-slider/angularjs-slider"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
