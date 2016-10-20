# -*- encoding: utf-8 -*-
# stub: foursquare2 2.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "foursquare2"
  s.version = "2.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Matt Mueller", "Marco Moura"]
  s.date = "2015-04-06"
  s.description = "Gives access to all endpoints in version 2 of foursquare's API with syntax that will be familiar to those who used the original foursquare gem by Jeremy Welch."
  s.email = ["muellermr@gmail.com", "email@marcomoura.com"]
  s.extra_rdoc_files = ["LICENSE.txt"]
  s.files = ["LICENSE.txt"]
  s.homepage = "http://github.com/mattmueller/foursquare2"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "Foursquare API v2 gem in the spirit of the original foursquare gem"

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, ["~> 0.8"])
      s.add_runtime_dependency(%q<faraday_middleware>, [">= 0.8"])
      s.add_runtime_dependency(%q<hashie>, ["< 4.0.0", ">= 1.0"])
      s.add_development_dependency(%q<awesome_print>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_development_dependency(%q<json_pure>, ["~> 1.4"])
      s.add_development_dependency(%q<multi_json>, ["< 2.0.0", ">= 0.0.5"])
      s.add_development_dependency(%q<test-unit>, ["~> 3.0"])
      s.add_development_dependency(%q<jnunemaker-matchy>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<faraday>, ["~> 0.8"])
      s.add_dependency(%q<faraday_middleware>, [">= 0.8"])
      s.add_dependency(%q<hashie>, ["< 4.0.0", ">= 1.0"])
      s.add_dependency(%q<awesome_print>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_dependency(%q<json_pure>, ["~> 1.4"])
      s.add_dependency(%q<multi_json>, ["< 2.0.0", ">= 0.0.5"])
      s.add_dependency(%q<test-unit>, ["~> 3.0"])
      s.add_dependency(%q<jnunemaker-matchy>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<faraday>, ["~> 0.8"])
    s.add_dependency(%q<faraday_middleware>, [">= 0.8"])
    s.add_dependency(%q<hashie>, ["< 4.0.0", ">= 1.0"])
    s.add_dependency(%q<awesome_print>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3"])
    s.add_dependency(%q<json_pure>, ["~> 1.4"])
    s.add_dependency(%q<multi_json>, ["< 2.0.0", ">= 0.0.5"])
    s.add_dependency(%q<test-unit>, ["~> 3.0"])
    s.add_dependency(%q<jnunemaker-matchy>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
