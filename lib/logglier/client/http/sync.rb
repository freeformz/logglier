require 'net/https'

module Logglier
  module Client
    class HTTP

      # Used to wrap and setup Net::HTTP as we need it
      class NetHTTPProxy

        # @param [URI] input_uri URI to deliver messages to
        # @param [Hash] opts Option hash
        # @option [Integer] read_timeout Read timeout for the http session. defaults to 2
        # @option [Integer] open_timeout Open timeout for the http session. defaults to 2
        # @option [Integer] verify_mode OpenSSL::SSL::VERIFY_* constant
        # @option [String] ca_file Path to the ca file
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
          retried = false
          begin
            @http.request_post(@input_uri.path, message)
          # We're using persistent connections, so connection can be closed by the other side
          # after a timeout. Don't consider it an error, just retry once.
          rescue Errno::ECONNRESET
            unless retried
              retried = true
              retry
            else
              $stderr.puts "WARNING: connection was reset while posting message: #{message}"
            end
          rescue TimeoutError, OpenSSL::SSL::SSLError, EOFError, Errno::ECONNRESET => e
            $stderr.puts "WARNING: #{e.class} posting message: #{message}"
          end
        end
      end

    end
  end
end
