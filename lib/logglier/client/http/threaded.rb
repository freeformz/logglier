require 'singleton'
require 'thread'
require 'monitor'

module Logglier

  module Client

    module HTTP

      class DeliveryThread < Thread

        def initialize(input_uri, read_timeout=120, open_timeout=120)

          @input_uri = input_uri

          @http = Net::HTTP.new(@input_uri.host, @input_uri.port)
          if @input_uri.scheme == 'https'
            @http.use_ssl = true
            @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end

          @http.read_timeout = read_timeout
          @http.open_timeout = open_timeout

          @queue = Queue.new
          @exiting = false

          super do
            until @exiting && @queue.empty?
              deliver(@queue.pop)
            end
          end

          at_exit {
            flush!
            join
          }
        end

        def flush!
          @exiting = true
          @queue.push(:__delivery_thread_exit_signal__)
        end

        def deliver(message)
          unless message == :__delivery_thread_exit_signal__
            begin
              @http.request_post(@input_uri.path, message)
            rescue TimeoutError => e
              $stderr.puts "WARNING: TimeoutError posting message: #{message}"
            end
          end
        end

        def push(message)
          @queue.push(message)
        end
      end

      class Threaded
        include Logglier::Client::InstanceMethods

        attr_reader :input_uri, :delivery_thread

        def initialize(opts={})
          setup_input_uri(opts)
          @delivery_thread = DeliveryThread.new(@input_uri, opts[:read_timeout] || 120, opts[:open_timeout] || 120)
        end

        # Required by Logger::LogDevice
        def write(message)
          @delivery_thread.push(message)
        end

        # Required by Logger::LogDevice
        def close
          nil
        end

      end
    end
  end
end
