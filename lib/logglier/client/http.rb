require 'net/https'
require 'uri'

module Logglier
  module Client
    module HTTP
      class NetHTTPProxy
        def initialize(input_uri, opts={})
          @input_uri = input_uri

          @http = Net::HTTP.new(@input_uri.host, @input_uri.port)

          if @input_uri.scheme == 'https'
            @http.use_ssl = true
            @http.verify_mode = opts[:verify_mode] || OpenSSL::SSL::VERIFY_PEER
            @http.ca_file = opts[:ca_file] if opts[:ca_file]
          end

          # We prefer persistent HTTP connections, so workaround http://redmine.ruby-lang.org/issues/4522
          @http.start

          @http.read_timeout = opts[:read_timeout] || 2
          @http.open_timeout = opts[:open_timeout] || 2
        end

        # Delivers the message via HTTP, handling errors
        #
        # @param [String] message The message to deliver
        def deliver(message)
          begin
            @http.request_post(@input_uri.path, message)
          rescue TimeoutError, OpenSSL::SSL::SSLError, EOFError, Errno::ECONNRESET => e
            $stderr.puts "WARNING: #{e.class} posting message: #{message}"
          end
        end
      end

      def self.new(opts={})
        if opts[:threaded]
          Logglier::Client::HTTP::Threaded.new(opts)
        else
          Logglier::Client::HTTP::Sync.new(opts)
        end
      end

    end
  end
end

require File.join(File.dirname(__FILE__), 'http', 'sync')
require File.join(File.dirname(__FILE__), 'http', 'threaded')
