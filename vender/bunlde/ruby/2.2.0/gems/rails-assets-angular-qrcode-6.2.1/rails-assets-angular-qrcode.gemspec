# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-qrcode/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-qrcode"
  spec.version       = RailsAssetsAngularQrcode::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = ""
  spec.summary       = ""
  spec.homepage      = "https://github.com/monospaced/angular-qrcode"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", ">= 1.0.6"
  spec.add_dependency "rails-assets-monospaced--bower-qrcode-generator", "0.1.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
