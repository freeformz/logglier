module Logglier
  module Client

    def self.new(opts={})
      if opts.nil? or opts.empty?
        raise InputURLRequired.new
      end
      
      opts = { :input_url => opts } if opts.is_a?(String)

      begin
        input_uri = URI.parse(opts[:input_url])
      rescue URI::InvalidURIError => e
        raise InputURLRequired.new("Invalid Input URL: #{input_uri}")
      end

      case input_uri.scheme
      when 'http', 'https'
        Logglier::Client::HTTP.new(opts)
      when 'udp', 'tcp'
        Logglier::Client::Syslog.new(opts)
      else
        raise Logglier::UnsupportedScheme.new("#{input_uri.scheme} is unsupported")
      end
      
    end

    module InstanceMethods

      def setup_input_uri(opts)
        @input_uri = opts[:input_url]

        begin
          @input_uri = URI.parse(@input_uri)
        rescue URI::InvalidURIError => e
          raise InputURLRequired.new("Invalid Input URL: #{@input_uri}")
        end
      end

    end

  end
end

require File.join(File.dirname(__FILE__), 'client', 'http')
require File.join(File.dirname(__FILE__), 'client', 'syslog')

