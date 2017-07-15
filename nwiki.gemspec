# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nwiki/version'

Gem::Specification.new do |spec|
  spec.name          = "nwiki"
  spec.version       = Nwiki::VERSION
  spec.authors       = ["niku"]
  spec.email         = ["niku@niku.name"]

  spec.summary       = %q{A generator for nikulog}
  spec.description   = %q{A generator for nikulog}
  spec.homepage      = "https://github.com/niku/nwiki"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "= 1.13.6" # ruby-bundler  https://packages.debian.org/stretch/ruby-bundler
  spec.add_development_dependency "rake",    "= 10.5.0" # rake          https://packages.debian.org/stretch/rake

  spec.add_dependency "rugged",   "= 0.24.0"            # ruby-rugged   https://packages.debian.org/stretch/ruby-rugged
  spec.add_dependency "nokogiri", "= 1.6.8.1"           # ruby-nokogiri https://packages.debian.org/stretch/ruby-nokogiri
  # It can't use ruby-org package in the debian.
  # Because there are too many commits between the master branch and the tag which the package points.
  spec.add_dependency "org-ruby", "~> 0.9"
end
