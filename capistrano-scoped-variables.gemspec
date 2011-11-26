# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "capistrano-scoped-variables"
  s.version     = "0.9.9"
  s.authors     = ["Ewout Vonk"]
  s.email       = ["dev@ewout.to"]
  s.homepage    = "https://github.com/ewoutvonk/capistrano-scoped-variables"
  s.summary     = %q{extensions which adds support for variables with different values, scoped to a specific server}
  s.description = %q{extensions which adds support for variables with different values, scoped to a specific server}

  s.rubyforge_project = "capistrano-scoped-variables"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "capistrano"
end
