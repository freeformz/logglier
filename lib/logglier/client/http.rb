require 'net/https'
require 'uri'

module Logglier

  module Client

    class HTTP
      include Logglier::Client::InstanceMethods

      attr_reader :input_uri, :http

      def initialize(opts={})
        setup_input_uri(opts)

        @http = Net::HTTP.new(@input_uri.host, @input_uri.port)
        if @input_uri.scheme == 'https'
          @http.use_ssl = true
          @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        @http.read_timeout = opts[:read_timeout] || 2
        @http.open_timeout = opts[:open_timeout] || 2
      end

      # Required by Logger::LogDevice
      def write(message)
        begin
          @http.start { @http.request_post(@input_uri.path, message) }
        rescue TimeoutError => e
          $stderr.puts "WARNING: TimeoutError posting message: #{message}"
        end
      end

      # Required by Logger::LogDevice
      def close
        nil
      end

    end
  end
end
