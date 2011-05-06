require 'net/https'
require 'uri'

module Logglier
  module Client
    module HTTP

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
