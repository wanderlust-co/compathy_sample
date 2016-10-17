# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-blueimp-canvas-to-blob/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-blueimp-canvas-to-blob"
  spec.version       = RailsAssetsBlueimpCanvasToBlob::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "JavaScript Canvas to Blob is a function to convert canvas elements into Blob objects."
  spec.summary       = "JavaScript Canvas to Blob is a function to convert canvas elements into Blob objects."
  spec.homepage      = "https://github.com/blueimp/JavaScript-Canvas-to-Blob"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
