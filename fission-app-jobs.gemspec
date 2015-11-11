$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission-app-jobs/version'
Gem::Specification.new do |s|
  s.name = 'fission-app-jobs'
  s.version = FissionApp::Jobs::VERSION.version
  s.summary = 'Fission App Jobs View'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/fission-app-jobs'
  s.description = 'Fission application jobs view'
  s.require_path = 'lib'
  s.add_dependency 'fission-app'
  s.add_dependency 'fission-app-multiuser'
  s.add_dependency 'd3c3-rails'
  s.files = Dir['{lib,app,config}/**/**/*'] + %w(fission-app-configs.gemspec README.md CHANGELOG.md)
end
