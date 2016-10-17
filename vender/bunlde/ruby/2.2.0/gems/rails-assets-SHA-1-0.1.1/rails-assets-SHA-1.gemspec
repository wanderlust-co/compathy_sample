# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-SHA-1/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-SHA-1"
  spec.version       = RailsAssetsSha1::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "This is a SHA-1 hash generator by JavaScript."
  spec.summary       = "This is a SHA-1 hash generator by JavaScript."
  spec.homepage      = "https://github.com/linkgod/SHA-1"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
