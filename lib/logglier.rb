require File.join(File.dirname(__FILE__), 'logglier', 'client')

require 'logger'

module Logglier

  class InputURLRequired < ArgumentError; end

  def self.new(opts={})
    Logger.new(Logglier::Client.new(opts))
  end

end
