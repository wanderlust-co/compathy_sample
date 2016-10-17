# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-daterangepicker/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-daterangepicker"
  spec.version       = RailsAssetsAngularDaterangepicker::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Angular.js wrapper for Dan Grosmann's bootstrap date range picker (https://github.com/dangrossman/bootstrap-daterangepicker)."
  spec.summary       = "Angular.js wrapper for Dan Grosmann's bootstrap date range picker (https://github.com/dangrossman/bootstrap-daterangepicker)."
  spec.homepage      = "https://github.com/fragaria/angular-daterangepicker"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", ">= 1.2.17", "< 2"
  spec.add_dependency "rails-assets-bootstrap", ">= 3.0.0", "< 4"
  spec.add_dependency "rails-assets-bootstrap-daterangepicker", ">= 2.0.0", "< 3"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
