require 'socket'
require 'uri'
require 'pp'

module Logglier

  module Client

    class Syslog
      include Logglier::Client::InstanceMethods

      attr_reader :input_uri, :facility

      def initialize(opts={})
        setup_input_uri(opts)
        @syslog = UDPSocket.new()
        @syslog.connect(@input_uri.host, @input_uri.port)

        unless @input_uri.path.empty?
          @facility = @input_uri.path.split('/')[1]
          if @facility and @facility.to_i <= 23 && @facility.to_i >= 0
            @facility = @facility.to_i
          else
            raise Logglier::UnknownFacility.new(@facility.to_s)
          end
        else
          @facility = 16
        end

        @hostname = Socket.gethostname.split('.').first
      end

      # Required by Logger::LogDevice
      def write(message)
        begin
          pp message
          @syslog.send(message,0)
        rescue TimeoutError => e
          $stderr.puts "WARNING: TimeoutError posting message: #{message}"
        end
      end

      # Required by Logger::LogDevice
      def close
        @syslog.close
      end

      # Specifies the date/time format for this client
      def datetime_format
        "%b %e %H:%M:%S"
      end

      # Syslog specific PRI calculation.
      # See RFC3164 4.1.1
      def pri(severity)
        @facility + case severity
        when "FATAL"
          0
        when "ERROR"
          3
        when "WARN"
          4
        when "INFO"
          6
        when "DEBUG"
          7
        end
      end

      # Generate a syslog compat message
      # See RFC3164 4.1.1 - 4.1.3
      def formatter
        proc do |severity, datetime, progname, msg|
          message = "<#{pri(severity)}>#{datetime.strftime(datetime_format)} #{@hostname} "
          if progname
            message << "#{progname}: "
          else
            message << "#{$0}: "
          end
          message << "severity=#{severity},"
          case msg
          when Hash
            msg.inject(message) {|m,v| m << "#{v[0]}=#{v[1]}" }
          when String
            message << msg
          else
            message << msg.inspect
          end
        end
      end

    end
  end
end
