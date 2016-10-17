# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-jquery-ujs/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-jquery-ujs"
  spec.version       = RailsAssetsJqueryUjs::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Ruby on Rails unobtrusive scripting adapter for jQuery"
  spec.summary       = "Ruby on Rails unobtrusive scripting adapter for jQuery"
  spec.homepage      = "https://github.com/rails/jquery-ujs"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-jquery", "> 1.8"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
