# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-sifter/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-sifter"
  spec.version       = RailsAssetsSifter::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "A library for textually searching arrays and hashes of objects by property (or multiple properties). Designed specifically for autocomplete."
  spec.summary       = "A library for textually searching arrays and hashes of objects by property (or multiple properties). Designed specifically for autocomplete."
  spec.homepage      = "https://github.com/brianreavis/sifter.js"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
