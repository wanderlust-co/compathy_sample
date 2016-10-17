# -*- encoding: utf-8 -*-
# stub: rails-assets-angular-nicescroll 0.0.9 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-assets-angular-nicescroll"
  s.version = "0.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["rails-assets.org"]
  s.date = "2015-12-22"
  s.description = "Angular Nicescroll Directive"
  s.homepage = "http://tushariscoolster.github.io/angular-nicescroll"
  s.licenses = ["LGPL-2.1"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "Angular Nicescroll Directive"

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails-assets-jquery.nicescroll>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rails-assets-jquery.nicescroll>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails-assets-jquery.nicescroll>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
