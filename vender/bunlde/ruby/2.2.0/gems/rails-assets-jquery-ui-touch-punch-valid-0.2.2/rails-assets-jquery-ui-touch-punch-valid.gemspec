# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-jquery-ui-touch-punch-valid/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-jquery-ui-touch-punch-valid"
  spec.version       = RailsAssetsJqueryUiTouchPunchValid::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "A duck punch for adding touch events to jQuery UI"
  spec.summary       = "A duck punch for adding touch events to jQuery UI"
  spec.homepage      = "https://github.com/cbier/bower-jquery-ui-touch-punch"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
