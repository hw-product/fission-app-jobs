$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission-app-jobs/version'
Gem::Specification.new do |s|
  s.name = 'fission-app-jobs'
  s.version = Fission::App::Jobs::VERSION.version
  s.summary = 'Fission Application Jobs'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/fission-app-jobs'
  s.description = 'Fission Application Jobs'
  s.require_path = 'lib'
  s.add_dependency 'fission'
  s.add_dependency 'fission-data'
  s.add_dependency 'octokit'
  s.files = Dir['**/*']
end
