# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "optimizely/version"

Gem::Specification.new do |s|
  s.name             = "optimizely"
  s.version          = Optimizely::VERSION
  s.platform         = Gem::Platform::RUBY
  s.author           = "Martijn Scheijbeler"
  s.email            = "martijn@marusem.com"
  s.homepage         = "https://github.com/martijnsch/optimizely-gem/"
  s.summary          = %q{The Optimizely Experiment API lets you create and manage Optimizely projects and experiments.}
  s.description      = %q{A Ruby gem to communicate with the Optimizely Experiments API, it lets you create and manage Optimizely projects and experiments.}

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths    = ["lib"]
  s.extra_rdoc_files = ["README.md"]
  s.add_development_dependency 'rake'
end