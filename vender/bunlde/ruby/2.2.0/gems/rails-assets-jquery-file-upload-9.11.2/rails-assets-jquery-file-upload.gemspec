# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-jquery-file-upload/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-jquery-file-upload"
  spec.version       = RailsAssetsJqueryFileUpload::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "File Upload widget with multiple file selection, drag&amp;drop support, progress bar, validation and preview images."
  spec.summary       = "File Upload widget with multiple file selection, drag&amp;drop support, progress bar, validation and preview images."
  spec.homepage      = "https://github.com/blueimp/jQuery-File-Upload"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-jquery", ">= 1.6"
  spec.add_dependency "rails-assets-blueimp-tmpl", ">= 2.5.4"
  spec.add_dependency "rails-assets-blueimp-load-image", ">= 1.13.0"
  spec.add_dependency "rails-assets-blueimp-canvas-to-blob", ">= 2.1.1"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
