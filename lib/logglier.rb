require 'net/https'
require 'uri'

require 'pp'

module Logglier

  class InputURLRequired < ArgumentError; end

  class Client

    attr_reader :input_uri

    def initialize(opts={})
      @input_uri = opts.is_a?(String) ? opts : opts[:input_url]

      if opts.nil? or opts.empty?
        raise InputURLRequired.new
      end

      begin
        @input_uri = URI.parse(@input_uri)
      rescue URI::InvalidURIError => e
        raise InputURLRequired.new("Invalid Input URL: #{@input_uri}")
      end

      @http = Net::HTTP.new(@input_uri.host, @input_uri.port)
      if @input_uri.scheme == 'https'
        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    # Required by Logger::LogDevice
    def write(message)
      @http.start { @http.request_post(@input_uri.path, message) }
    end

    # Required by Logger::LogDevice
    def close
      nil
    end
  end

end
