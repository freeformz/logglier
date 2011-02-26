require 'net/http'
require 'uri'

require 'pp'

module Logglier

  class InputURLRequired < ArgumentError; end

  class Client

    attr_reader :input_url

    def initialize(opts={})
      @input_url = opts.is_a?(String) ? opts : opts[:input_url]

      if opts.nil? or opts.empty?
        raise InputURLRequired.new
      end

      begin
        @input_uri = URI.parse(@input_url)
      rescue URI::InvalidURIError => e
        raise InputURLRequired.new("Invalid Input URL: #{@input_url}")
      end
    end

    # Required by Logger::LogDevice
    def write(message)
      request = Net::HTTP::Post.new(@input_uri.path)
      request.body = message
      response = Net::HTTP.start(@input_uri.host, @input_uri.port) {|http| http.request(request)}
      pp resposnse
    end

    # Required by Logger::LogDevice
    def close
      nil
    end
  end

end
