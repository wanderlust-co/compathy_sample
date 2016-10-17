# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-restangular/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-restangular"
  spec.version       = RailsAssetsRestangular::VERSION
  spec.authors       = ["rails-assets.tenex.tech"]
  spec.description   = "Restful Resources service for AngularJS apps"
  spec.summary       = "Restful Resources service for AngularJS apps"
  spec.homepage      = "https://github.com/mgonto/restangular"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-lodash", ">= 1.3.0"
  spec.add_dependency "rails-assets-angular", "~> 1.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
