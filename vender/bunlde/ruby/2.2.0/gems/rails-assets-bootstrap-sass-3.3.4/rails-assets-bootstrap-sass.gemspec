# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-bootstrap-sass/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-bootstrap-sass"
  spec.version       = RailsAssetsBootstrapSass::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "bootstrap-sass is a Sass-powered version of Bootstrap, ready to drop right into your Sass powered applications."
  spec.summary       = "bootstrap-sass is a Sass-powered version of Bootstrap, ready to drop right into your Sass powered applications."
  spec.homepage      = "https://github.com/twbs/bootstrap-sass"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-jquery", ">= 1.9.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
