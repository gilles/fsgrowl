# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fsgrowl/version"

Gem::Specification.new do |s|
  s.name = "fsgrowl"
  s.version = Fsgrowl::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Gilles Devaux"]
  s.email = ["TODO: Write your email address"]
  s.homepage = "http://rubygems.org/gems/fsgrowl"
  s.summary = "Growl notifier for Formspring.me"
  s.description = "Growl notifier for Formspring.me"

  s.rubyforge_project = "fsgrowl"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.bindir = 'bin'
  s.executables=%w(fsgrowl)

  s.add_dependency "nokogiri"
  s.add_dependency "json"
  s.add_dependency "daemons"

  s.add_development_dependency "rake"

end
