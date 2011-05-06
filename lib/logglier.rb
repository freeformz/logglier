require File.join(File.dirname(__FILE__), 'logglier', 'client')

require 'logger'

module Logglier

  class InputURLRequired < ArgumentError; end
  class UnsupportedScheme < ArgumentError; end
  class UnknownFacility < ArgumentError; end

  def self.new(url, opts={})
    client = Logglier::Client.new(url, opts)
    logger = Logger.new(client)

    if client.respond_to?(:formatter)
      logger.formatter = client.formatter
    elsif client.respond_to?(:datetime_format)
      logger.datetime_format = client.datetime_format
    end

    logger
  end

end
