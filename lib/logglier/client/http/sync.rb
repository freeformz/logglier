require 'net/https'

module Logglier
  module Client
    class HTTP

      # Used to wrap and setup Net::HTTP as we need it
      class NetHTTPProxy

        RETRY_EXCEPTIONS = [
          TimeoutError, OpenSSL::SSL::SSLError, Errno::EPIPE,
          EOFError, Errno::ECONNRESET, Errno::ETIMEDOUT,
          Errno::ECONNREFUSED
        ]

        RETRIES = 3

        attr_accessor :failsafe

        # @param [URI] input_uri URI to deliver messages to
        # @param [Hash] opts Option hash
        # @option [Integer] read_timeout Read timeout for the http session. defaults to 2
        # @option [Integer] open_timeout Open timeout for the http session. defaults to 2
        # @option [Integer] verify_mode OpenSSL::SSL::VERIFY_* constant
        # @option [String] ca_file Path to the ca file
        # @option [IO] failsafe Where to `#puts` delivery errors. defaults to `$stderr`
        def initialize(input_uri, opts={})
          @input_uri = input_uri
          @verify_mode = opts[:verify_mode] || OpenSSL::SSL::VERIFY_PEER
          @ca_file = opts[:ca_file]
          @read_timeout = opts[:read_timeout] || 5
          @open_timeout = opts[:open_timeout] || 5
          @failsafe = opts[:failsafe] || $stderr
          @format = opts[:format] ? opts[:format].to_sym : nil
          @headers = {}
          if @format == :json
            @headers['Content-Type'] = 'application/json'
          end

          connect!
        end

        # Delivers the message via HTTP, handling errors
        #
        # @param [String] message The message to deliver
        def deliver(message)
          retries = 0

          begin
            @http.request_post(@input_uri.path, message, @headers)
          rescue *RETRY_EXCEPTIONS => e
            if retries < RETRIES
              retries += 1
              failsafe_retrying(e, message, retries)
              sleep retries
              connect!
              retry
            else
              failsafe_errored(e, message)
            end
          rescue Exception => e
            failsafe_errored(e, message)
          end
        end

        private

        def connect!
          @http = Net::HTTP.new(@input_uri.host, @input_uri.port)

          if @input_uri.scheme == 'https'
            @http.use_ssl = true
            @http.verify_mode = @verify_mode
            @http.ca_file = @ca_file if @ca_file
          end

          # We prefer persistent HTTP connections, so workaround http://redmine.ruby-lang.org/issues/4522
          # This causes problems with 1.8.6, so don't do it there.
          @http.start unless RUBY_VERSION == "1.8.6"

          @http.read_timeout = @read_timeout
          @http.open_timeout = @open_timeout

        end

        def failsafe_retrying(exception, message, retries)
          @failsafe.puts "WARNING: [#{retries}/#{RETRIES}] " + failsafe_message(exception, message)
        end

        def failsafe_errored(exception, message)
          @failsafe.puts "ERROR: " + failsafe_message(exception, message)
        end

        def failsafe_message(exception, message)
          "caught `#{exception.class}: #{exception.message}` while attempting to deliver: #{message}"
        end
      end

    end
  end
end
