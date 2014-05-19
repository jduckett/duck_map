# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "duck_map/version"

Gem::Specification.new do |s|
  s.name        = "duck_map"
  s.version     = DuckMap::VERSION
  s.authors     = ["Jeff Duckett"]
  s.email       = ["jeff.duckett@gmail.com"]
  s.homepage    = "http://www.jeffduckett.com/"
  s.summary     = %q{Duck Map is a Rails 4.x compliant gem providing support for dynamically generating sitemaps and meta tags in HTML page headers.}
  s.description = %q{Duck Map is a Rails 4.x compliant gem providing support for dynamically generating sitemaps and meta tags in HTML page headers.}

  s.rubyforge_project = "duck_map"

  s.files = Dir.glob("lib/**/*")
  s.files.concat(Dir.glob("app/**/*"))
  s.files.concat(Dir.glob("config/**/*"))

  s.require_paths = ["lib"]

#  s.add_dependency "rails", "~> 4.0.1"

  s.add_development_dependency "sqlite3"

  s.add_runtime_dependency "highline"

end
