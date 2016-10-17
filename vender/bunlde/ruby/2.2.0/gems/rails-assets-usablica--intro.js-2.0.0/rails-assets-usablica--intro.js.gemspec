# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-usablica--intro.js/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-usablica--intro.js"
  spec.version       = RailsAssetsUsablicaIntroJs::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "A better way for new feature introduction and step-by-step users guide for your website and project."
  spec.summary       = "A better way for new feature introduction and step-by-step users guide for your website and project."
  spec.homepage      = "http://usablica.github.com/intro.js"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
