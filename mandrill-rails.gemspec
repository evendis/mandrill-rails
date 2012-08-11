# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mandrill-rails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Gallagher"]
  gem.email         = ["gallagher.paul@gmail.com"]
  gem.description   = %q{Rails integration for working with Mandrill}
  gem.summary       = %q{Rails integration for working with Mandrill}
  gem.homepage      = "https://github.com/evendis/mandrill-rails"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mandrill-rails"
  gem.require_paths = ["lib"]
  gem.version       = Mandrill::Rails::VERSION

  gem.add_runtime_dependency(%q<mandrill>, ["~> 0.0.2"])
  gem.add_runtime_dependency(%q<activesupport>, [">= 3.0.3"])
  gem.add_development_dependency(%q<bundler>, ["~> 1.1.4"])
  gem.add_development_dependency(%q<rake>, ["~> 0.9.2.2"])
  gem.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
  gem.add_development_dependency(%q<rdoc>, ["~> 3.11"])
  gem.add_development_dependency(%q<guard-rspec>, ["~> 1.2.0"])

end
