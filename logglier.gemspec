dir = File.dirname(__FILE__)
require File.expand_path(File.join(dir, 'lib', 'logglier', 'version'))

Gem::Specification.new do |s|
  s.name              = 'logglier'
  s.version           = Logglier::VERSION
  s.date              = Time.now
  s.summary           = 'Loggly "plugin" for Logger'
  s.description       = 'Logger => Loggly'

  s.license = "http://opensource.org/licenses/Apache-2.0"

  s.authors           = ["Edward Muller (aka freeformz)"]
  s.email             = 'edwardam@interlix.com'
  s.homepage          = 'http://github.com/freeformz/logglier'

  s.files             = %w{ README.md Gemfile LICENSE logglier.gemspec Rakefile } + Dir["lib/**/*.rb"]
  s.require_paths     = ['lib']
  s.test_files        = Dir["spec/**/*.rb"]

  s.rubyforge_project = 'logglier'

  s.required_ruby_version     = '>= 1.8.6'
  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency 'multi_json', '~> 0'
  s.add_development_dependency 'rake', '~> 0'
  s.add_development_dependency 'rspec', '~> 2.11', '>= 2.11.0'
end


