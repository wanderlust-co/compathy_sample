# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-intro.js/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-intro.js"
  spec.version       = RailsAssetsAngularIntroJs::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Angular directive to wrap intro.js"
  spec.summary       = "Angular directive to wrap intro.js"
  spec.homepage      = "https://github.com/mendhak/angular-intro.js"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", "~> 1.4.0"
  spec.add_dependency "rails-assets-usablica--intro.js", "2.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
