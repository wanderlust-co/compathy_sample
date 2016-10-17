# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-blueimp-load-image/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-blueimp-load-image"
  spec.version       = RailsAssetsBlueimpLoadImage::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "JavaScript Load Image is a library to load images provided as File or Blob objects or via URL. It returns an optionally scaled and/or cropped HTML img or canvas element. It also provides a method to parse image meta data to extract Exif tags and thumbnails and to restore the complete image header after resizing."
  spec.summary       = "JavaScript Load Image is a library to load images provided as File or Blob objects or via URL. It returns an optionally scaled and/or cropped HTML img or canvas element. It also provides a method to parse image meta data to extract Exif tags and thumbnails and to restore the complete image header after resizing."
  spec.homepage      = "https://github.com/blueimp/JavaScript-Load-Image"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
