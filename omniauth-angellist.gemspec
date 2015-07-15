$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'omniauth-angellist/version'

Gem::Specification.new do |s|
  s.name        = 'omniauth-angellist'
  s.version     = Omniauth::AngelList::VERSION
  s.authors     = ['Sebastian Rabuini']
  s.email       = ['srabuini@gmail.com']
  s.homepage    = 'https://github.com/wasabit/omniauth-angellist'
  s.summary     = 'AngelList OAuth strategy for OmniAuth'
  s.description = 'AngelList OAuth strategy for OmniAuth'
  s.license     = 'MIT'

  s.rubyforge_project = 'omniauth-angellist'

  s.files         = `git ls-files`.split('\n')
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split('\n')

  s.require_paths = ['lib']

  s.add_runtime_dependency 'omniauth-oauth2', '~> 1.1'
  s.add_development_dependency 'rspec', '~> 2.7'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'webmock'
end
