# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-translate-storage-cookie/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-translate-storage-cookie"
  spec.version       = RailsAssetsAngularTranslateStorageCookie::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "A plugin for Angular Translate"
  spec.summary       = "A plugin for Angular Translate"
  spec.homepage      = "https://github.com/PascalPrecht/bower-angular-translate-storage-cookie"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular-translate", "~> 2.12.1"
  spec.add_dependency "rails-assets-angular-cookies", ">= 1.2.26", "< 1.6"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
