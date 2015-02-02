# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ardm/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = [ 'Martin Emde', 'Dan Kubb' ]
  gem.email         = [ "me@martinemde.com" ]
  gem.summary       = "ActiveRecord plugin to provide a smooth migration from DataMapper to ActiveRecord"
  gem.description   = gem.summary
  gem.homepage      = "http://github.com/engineyard/ardm"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE README.md]

  gem.name          = "ardm"
  gem.require_paths = [ "lib" ]
  gem.version       = Ardm::VERSION

  gem.add_runtime_dependency 'activesupport', '>= 3.2', '< 5.0'
  gem.add_runtime_dependency 'bcrypt',        '~> 3.0'
  gem.add_runtime_dependency 'fastercsv',     '~> 1.5'
  gem.add_runtime_dependency 'multi_json',    '> 1.3'
  gem.add_runtime_dependency 'stringex',      '~> 1.3'
  gem.add_runtime_dependency 'uuidtools',     '~> 2.1'
  gem.add_runtime_dependency 'coercible'

  gem.add_development_dependency 'rake',  '~> 0.9'
  gem.add_development_dependency 'rspec', '~> 2.0'
end
