require File.join(File.dirname(__FILE__), 'logglier', 'client')

require 'logger'

module Logglier

  class InputURLRequired < ArgumentError; end
  class UnsupportedScheme < ArgumentError; end
  class UnknownFacility < ArgumentError; end

  def self.new(url, opts={})
    client = Logglier::Client.new(url, opts)
    logger = ActiveSupport::Logger.new(client)

    # KK: Logglier's formatter is great for JSON but nasty for text.
    # It spits out lines like this:
    #
    # 2013-03-09 14:21:23 -0800 severity=DEBUG,
    #
    # ...which are useless. Moreover, the logs show up without newlines in
    # the console, which makes them illegible.
    # Let's just use SimpleFormatter (the default) when we're dealing with text logs.
    # This is a hack and the real fix should be fixing the formatter within Logglier.

    if client.respond_to?(:formatter) &&
      if opts[:format] == :json
        logger.formatter = client.formatter
      else
        logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      end
    elsif client.respond_to?(:datetime_format)
      logger.datetime_format = client.datetime_format
    end

    logger
  end

end
