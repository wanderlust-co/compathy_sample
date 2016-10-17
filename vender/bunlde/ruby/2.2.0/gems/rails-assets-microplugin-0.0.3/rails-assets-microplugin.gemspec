# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-microplugin/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-microplugin"
  spec.version       = RailsAssetsMicroplugin::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "A lightweight plugin / dependency system for javascript libraries."
  spec.summary       = "A lightweight plugin / dependency system for javascript libraries."
  spec.homepage      = "https://github.com/brianreavis/microplugin.js"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
