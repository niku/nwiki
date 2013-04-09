# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nwiki/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['niku']
  gem.email         = ['niku@niku.name']
  gem.description   = %q{Write a gem description}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'nwiki'
  gem.require_paths = ['lib']
  gem.version       = Nwiki::VERSION

  gem.add_dependency('gollum-lib')
  gem.add_dependency('rack')
  gem.add_dependency('org-ruby')

  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('rack-test')
  gem.add_development_dependency('guard')
  gem.add_development_dependency('guard-rspec')
  gem.add_development_dependency('ruby_gntp')
end
