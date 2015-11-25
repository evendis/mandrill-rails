# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mandrill-rails/version', __FILE__)

Gem::Specification.new do |spec|
  spec.authors       = ["Paul Gallagher"]
  spec.email         = ["gallagher.paul@gmail.com"]
  spec.description   = "Rails integration for Mandrill"
  spec.summary       = "Provides webhook processing and event decoration to make using Mandrill with Rails just that much easier"
  spec.homepage      = "https://github.com/evendis/mandrill-rails"
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.name          = "mandrill-rails"
  spec.require_paths = ["lib"]
  spec.version       = Mandrill::Rails::VERSION

  spec.add_runtime_dependency "activesupport", ">= 3.0.3"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "generator_spec", "~> 0.9"
  spec.add_development_dependency "guard-rspec", "~> 4.5"
  spec.add_development_dependency "rdoc"

end
