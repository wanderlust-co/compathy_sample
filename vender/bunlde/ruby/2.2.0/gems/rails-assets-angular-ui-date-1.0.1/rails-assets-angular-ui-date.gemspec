# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-ui-date/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-ui-date"
  spec.version       = RailsAssetsAngularUiDate::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "This directive allows you to add a date-picker to your form elements."
  spec.summary       = "This directive allows you to add a date-picker to your form elements."
  spec.homepage      = "http://angular-ui.github.com/ui-date"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", ">= 1.3.0", "< 2"
  spec.add_dependency "rails-assets-jquery-ui", ">= 1.9", "< 2"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
