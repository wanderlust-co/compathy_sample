# -*- encoding: utf-8 -*-
# stub: rails-assets-angular-local-storage 0.5.2 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-assets-angular-local-storage"
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["rails-assets.org"]
  s.date = "2016-09-28"
  s.description = "An Angular module that gives you access to the browser's local storage"
  s.homepage = "http://gregpike.net/demos/angular-local-storage/demo.html"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "An Angular module that gives you access to the browser's local storage"

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails-assets-angular>, ["< 2", ">= 1.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rails-assets-angular>, ["< 2", ">= 1.0"])
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails-assets-angular>, ["< 2", ">= 1.0"])
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
