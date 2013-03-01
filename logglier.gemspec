dir = File.dirname(__FILE__)
require File.expand_path(File.join(dir, 'lib', 'logglier', 'version'))

Gem::Specification.new do |s|
  s.name              = 'logglier'
  s.version           = Logglier::VERSION
  s.date              = Time.now
  s.summary           = 'Loggly "plugin" for ActiveSupport::Logger'
  s.description       = 'ActiveSupport::Logger => Loggly'

  s.authors           = ["Edward Muller (aka freeformz)"]
  s.email             = 'edwardam@interlix.com'
  s.homepage          = 'http://github.com/freeformz/logglier'

  s.files             = %w{ README.md Gemfile LICENSE logglier.gemspec Rakefile } + Dir["#{dir}/lib/**/*.rb"]
  s.require_paths     = ['lib']
  s.test_files        = Dir["#{dir}/spec/**/*.rb"]

  s.rubyforge_project = 'logglier'

  s.required_ruby_version     = '>= 1.8.6'
  s.required_rubygems_version = '>= 1.3.6'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.11.0'
  s.add_development_dependency 'multi_json'
end


