# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-monospaced--bower-qrcode-generator/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-monospaced--bower-qrcode-generator"
  spec.version       = RailsAssetsMonospacedBowerQrcodeGenerator::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = ""
  spec.summary       = ""
  spec.homepage      = "https://github.com/monospaced/bower-qrcode-generator"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
