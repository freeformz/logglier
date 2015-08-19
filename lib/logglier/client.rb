require 'multi_json'

module Logglier
  module Client

    # Creates a new loggly client, based on a url scheme and options provided
    # @param [Hash,String] opts the options hash or url string
    # @option opts [String] :input_url The Loggly input_url
    #
    # If a url string is passed, it becomes {:input_url => <string>}
    #
    #
    # @raise [Logglier::UnsupportedScheme] if the :input_url isn't recognized
    # @return [Logglier::Client::HTTP, Logglier::Client::Syslog] returns an instance of the Logglier Client class 
    def self.new(input_url, opts={})
      unless input_url
        raise InputURLRequired.new
      end

      opts.merge!({ :input_url => input_url })

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

      def masherize_key(prefix,key)
        [prefix,key.to_s].compact.join('.')
      end

      def masher(hash, prefix=nil)
        hash.map do |v|
          if v[1].is_a?(Hash)
            masher(v[1],masherize_key(prefix,v[0]))
          else
            "#{masherize_key(prefix,v[0])}=" << case v[1]
            when Symbol
              v[1].to_s
            else
              v[1].inspect
            end
          end
        end.join(", ")
      end

      def formatter
        proc do |severity, datetime, progname, msg|
          processid=Process.pid
          if @format == :json && msg.is_a?(Hash)
            MultiJson.dump(msg.merge({ :severity => severity,
                                       :datetime => datetime,
                                       :progname => progname,
                                       :pid      => processid }))
          else
            message = "#{datetime} "
            message << massage_message(msg, severity, processid)
          end
        end
      end

      def massage_message(incoming_message, severity, processid)
        outgoing_message = ""
        outgoing_message << "severity=#{severity}, pid=#{processid}, "
        case incoming_message
        when Hash
          outgoing_message << masher(incoming_message)
        when String
          outgoing_message << incoming_message
        else
          outgoing_message << incoming_message.inspect
        end
        outgoing_message
      end

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

