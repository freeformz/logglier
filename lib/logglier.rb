require File.join(File.dirname(__FILE__), 'logglier', 'client')

require 'logger'

module Logglier

  class InputURLRequired < ArgumentError; end
  class UnsupportedScheme < ArgumentError; end
  class UnknownFacility < ArgumentError; end

  def self.new(opts={})
    client = Logglier::Client.new(opts)
    logger = Logger.new(client)

    if client.respond_to?(:formatter)
      logger.formatter = client.formatter
    end

    if client.respond_to?(:datetime_format)
      logger.datetime_format = client.datetime_format
    end

    $client = client

    logger
  end

end
