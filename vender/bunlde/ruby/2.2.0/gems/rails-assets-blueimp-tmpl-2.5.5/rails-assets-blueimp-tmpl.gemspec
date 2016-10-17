# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-blueimp-tmpl/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-blueimp-tmpl"
  spec.version       = RailsAssetsBlueimpTmpl::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "< 1KB lightweight, fast & powerful JavaScript templating engine with zero dependencies. Compatible with server-side environments like node.js, module loaders like RequireJS and all web browsers."
  spec.summary       = "< 1KB lightweight, fast & powerful JavaScript templating engine with zero dependencies. Compatible with server-side environments like node.js, module loaders like RequireJS and all web browsers."
  spec.homepage      = "https://github.com/blueimp/JavaScript-Templates"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
