# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-angular-bootstrap/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-angular-bootstrap"
  spec.version       = RailsAssetsAngularBootstrap::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Native AngularJS (Angular) directives for Bootstrap."
  spec.summary       = "Native AngularJS (Angular) directives for Bootstrap."
  spec.homepage      = "https://github.com/angular-ui/bootstrap-bower"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-angular", ">= 1.4.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
