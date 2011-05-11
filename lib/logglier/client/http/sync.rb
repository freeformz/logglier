module Logglier

  module Client

    module HTTP

      class Sync
        include Logglier::Client::InstanceMethods
        include Logglier::Client::HTTP::InstanceMethods

        attr_reader :input_uri, :http

        def initialize(opts={})
          setup_input_uri(opts)

          setup_http(opts)
        end

        # Required by Logger::LogDevice
        def write(message)
          deliver(message)
        end

        # Required by Logger::LogDevice
        def close
          nil
        end

      end
    end
  end
end
