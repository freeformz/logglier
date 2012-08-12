require 'thread'

module Logglier
  module Client
    class HTTP

      # Used by the Threaded client to manage the delivery thread
      # recreating it if is lost due to a fork.
      #
      class DeliveryThreadManager
        def initialize(input_uri, opts={})
          @input_uri, @opts = input_uri, opts
          start_thread
        end

        # Pushes a message to the delivery thread, starting one if necessary
        def deliver(message)
          start_thread unless @thread.alive?
          @thread.deliver(message)
          #Race condition? Sometimes we need to rescue this and start a new thread
        rescue NoMethodError
          @thread.kill #Try not to leak threads, should already be dead anyway
          start_thread
          retry
        end

        private

        def start_thread
          @thread = DeliveryThread.new(@input_uri, @opts)
        end
      end

      # Used by the DeliveryThreadManager to hold a queue, deliver messsages from it
      # and to ensure it's flushed on program exit.
      #
      # @note Uses NetHTTPProxy
      #
      class DeliveryThread < Thread

        # @param [URI] input_uri The uri to deliver messages to
        # @param [Hash] opts Option hash
        # @option [Integer] read_timeout Read timeout for the http session. defaults to 120
        # @option [Integer] open_timeout Open timeout for the http session. defaults to 120
        #
        # @note See NetHTTPProxy for further option processing of opts
        # @note registers an at_exit handler that signals exit intent and joins the thread.
        def initialize(input_uri, opts={})
          @input_uri = input_uri

          opts[:read_timeout] = opts[:read_timeout] || 120
          opts[:open_timeout] = opts[:open_timeout] || 120

          @http = Logglier::Client::HTTP::NetHTTPProxy.new(@input_uri, opts)

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
        def deliver(message)
          @queue.push(message)
        end
      end

    end
  end
end
