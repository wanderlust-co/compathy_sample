# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-iscroll/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-iscroll"
  spec.version       = RailsAssetsAngularIscroll::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "AngularJS module that enables iScroll 5 functionality, wrapping it in an easy-to-use directive."
  spec.summary       = "AngularJS module that enables iScroll 5 functionality, wrapping it in an easy-to-use directive."
  spec.homepage      = "https://github.com/mtr/angular-iscroll"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", ">= 1.2"
  spec.add_dependency "rails-assets-platform", ">= 1.3"
  spec.add_dependency "rails-assets-iscroll", ">= 5.2.0", "< 6"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
