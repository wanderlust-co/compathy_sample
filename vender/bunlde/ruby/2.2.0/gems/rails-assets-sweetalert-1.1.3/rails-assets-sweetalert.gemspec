# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-sweetalert/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-sweetalert"
  spec.version       = RailsAssetsSweetalert::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "A beautiful replacement for JavaScript's alert."
  spec.summary       = "A beautiful replacement for JavaScript's alert."
  spec.homepage      = "http://tristanedwards.me/sweetalert"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
