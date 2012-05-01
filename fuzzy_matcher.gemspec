# -*- encoding: utf-8 -*-
require File.expand_path('../lib/fuzzy_matcher/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kirill Zonov"]
  gem.email         = ["graffzon@gmail.com"]
  gem.description   = %q{fuzzy matcher}
  gem.summary       = %q{smth..}
  gem.homepage      = ""

  gem.add_dependency "pg"
  gem.add_dependency "mysql2"

  # gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fuzzy_matcher"
  gem.require_paths = ["lib"]
  gem.version       = FuzzyMatcher::VERSION
  gem.files        = Dir["lib/**/*", "[A-Z]*"] - ["Gemfile.lock"]
end
