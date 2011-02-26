$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'lib/logglier'

RSpec.configure do |config|
  config.color_enabled = config.tty = true

  config.before(:each) do
  end

end

