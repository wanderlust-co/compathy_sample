# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-ui-sortable/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-ui-sortable"
  spec.version       = RailsAssetsAngularUiSortable::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = ""
  spec.summary       = ""
  spec.homepage      = "https://github.com/angular-ui/ui-sortable"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", ">= 1.2"
  spec.add_dependency "rails-assets-jquery", "< 3.0.0"
  spec.add_dependency "rails-assets-jquery-ui", ">= 1.9"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
