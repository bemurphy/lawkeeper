# -*- encoding: utf-8 -*-
require File.expand_path('../lib/lawkeeper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Brendon Murphy"]
  gem.email         = ["xternal1+github@gmail.com"]
  gem.summary       = %q{Lawkeeper - Simple authorization policies for Rack apps}
  gem.description   = gem.summary
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "lawkeeper"
  gem.require_paths = ["lib"]
  gem.version       = Lawkeeper::VERSION

  gem.add_development_dependency "minitest"
end
