require 'thread'

module Logglier

  module Client

    module HTTP

      # Used by the Threaded client to hold a queue, deliver messsages from it
      # and to ensure it's flushed on program exit.
      #
      # Not meant to be used directly.
      class DeliveryThread < Thread

        # @param [URI] input_uri The uri to deliver messags to
        # @param [Integer] read_timeout Read timeout for the http session. defaults to 120
        # @param [Integer] open_timeout Open timeout for the http session. defaults to 120
        #
        # @note registers an at_exit handler that signals exit intent and joins the thread.
        def initialize(input_uri, read_timeout=120, open_timeout=120)

          @input_uri = input_uri

          @http = NetHTTPProxy.new(@input_uri, {:read_timeout => read_timeout, :open_timeout => open_timeout} )

          @queue = Queue.new
          @exiting = false

          super do
            loop do
              msg = @queue.pop
              break if msg == :__delivery_thread_exit_signal__
              @http.deliver(msg)
            end
          end

          at_exit {
            exit!
            join
          }
        end

        # Signals the queue that we're exiting
        def exit!
          @exiting = true
          @queue.push :__delivery_thread_exit_signal__
        end

        # Pushes a message onto the internal queue
        def push(message)
          @queue.push(message)
        end
      end

      # Interface to the DeliveryThread
      class Threaded
        include Logglier::Client::InstanceMethods

        attr_reader :input_uri, :delivery_thread

        def initialize(opts={})
          setup_input_uri(opts)
          @delivery_thread = DeliveryThread.new(@input_uri, opts[:read_timeout] || 120, opts[:open_timeout] || 120)
        end

        # Required by Logger::LogDevice
        # @param [String] message the message to deliver
        #
        # @note doesn't do actual deliver. Pushes the messages off to the delivery thread
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
