# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mandrill-rails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Gallagher"]
  gem.email         = ["gallagher.paul@gmail.com"]
  gem.description   = %q{Rails integration for Mandrill}
  gem.summary       = %q{Provides webhook processing and event decoration to make using Mandrill with Rails just that much easier}
  gem.homepage      = "https://github.com/evendis/mandrill-rails"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mandrill-rails"
  gem.require_paths = ["lib"]
  gem.version       = Mandrill::Rails::VERSION

  gem.add_runtime_dependency(%q<activesupport>, [">= 3.0.3"])
  gem.add_development_dependency(%q<bundler>, [">= 1.1.0"])
  gem.add_development_dependency(%q<rake>, ["~> 0.9.2.2"])
  gem.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
  gem.add_development_dependency(%q<rdoc>, ["~> 3.11"])
  gem.add_development_dependency(%q<guard-rspec>, ["~> 1.2.0"])

end
