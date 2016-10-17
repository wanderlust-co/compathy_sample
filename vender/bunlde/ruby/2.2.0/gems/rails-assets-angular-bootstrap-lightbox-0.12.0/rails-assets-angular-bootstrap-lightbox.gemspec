# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-bootstrap-lightbox/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-bootstrap-lightbox"
  spec.version       = RailsAssetsAngularBootstrapLightbox::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = ""
  spec.summary       = ""
  spec.homepage      = "https://github.com/compact/angular-bootstrap-lightbox"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", ">= 1.4.10", "< 2"
  spec.add_dependency "rails-assets-angular-bootstrap", ">= 1.3.1", "< 2"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
