# -*- encoding: utf-8 -*-
# stub: rails-assets-sifter 0.5.2 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-assets-sifter"
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["rails-assets.org"]
  s.date = "2016-09-16"
  s.description = "A library for textually searching arrays and hashes of objects by property (or multiple properties). Designed specifically for autocomplete."
  s.homepage = "https://github.com/brianreavis/sifter.js"
  s.licenses = ["Apache License, Version 2.0"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "A library for textually searching arrays and hashes of objects by property (or multiple properties). Designed specifically for autocomplete."

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
