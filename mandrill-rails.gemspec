# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mandrill-rails/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'mandrill-rails'
  spec.version       = Mandrill::Rails::VERSION
  spec.authors       = ['Paul Gallagher']
  spec.email         = ['gallagher.paul@gmail.com']
  spec.description   = 'Rails integration for Mandrill'
  spec.summary       = 'Provides webhook processing and event decoration to make using Mandrill with Rails just that much easier'
  spec.homepage      = 'https://github.com/evendis/mandrill-rails'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 4', '< 7.0'

  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'bundler', '>= 2.2.33'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'generator_spec'
  spec.add_development_dependency 'guard-rspec'
end
