# -*- encoding: utf-8 -*-
# stub: rails-assets-microplugin 0.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-assets-microplugin"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["rails-assets.org"]
  s.date = "2015-02-23"
  s.description = "A lightweight plugin / dependency system for javascript libraries."
  s.homepage = "https://github.com/brianreavis/microplugin.js"
  s.licenses = ["Apache License, Version 2.0"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "A lightweight plugin / dependency system for javascript libraries."

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
