require File.join(File.dirname(__FILE__), 'logglier', 'client')

module Logglier

  class InputURLRequired < ArgumentError; end

  def self.new(opts={})
    Logglier::Client.new(opts)
  end

end
