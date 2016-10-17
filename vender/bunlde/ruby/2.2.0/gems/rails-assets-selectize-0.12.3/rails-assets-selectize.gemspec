# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-selectize/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-selectize"
  spec.version       = RailsAssetsSelectize::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Selectize is a jQuery-based custom <select> UI control. Useful for tagging, contact lists, country selectors, etc."
  spec.summary       = "Selectize is a jQuery-based custom <select> UI control. Useful for tagging, contact lists, country selectors, etc."
  spec.homepage      = "https://github.com/selectize/selectize.js"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-jquery", ">= 1.7.0"
  spec.add_dependency "rails-assets-sifter", "~> 0.5.0"
  spec.add_dependency "rails-assets-microplugin", "~> 0.0.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
