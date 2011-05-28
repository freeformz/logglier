module Logglier

  module Client

    module HTTP

      class Sync
        include Logglier::Client::InstanceMethods

        attr_reader :input_uri, :http

        def initialize(opts={})
          setup_input_uri(opts)
          @http = NetHTTPProxy.new(@input_uri,opts)
        end

        # Required by Logger::LogDevice
        def write(message)
          @http.deliver(message)
        end

        # Required by Logger::LogDevice
        def close
          nil
        end

      end
    end
  end
end
