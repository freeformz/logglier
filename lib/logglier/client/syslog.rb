require 'socket'
require 'uri'
require 'pp'

module Logglier

  module Client

    class Syslog
      include Logglier::Client::InstanceMethods

      attr_reader :input_uri, :facility, :format, :syslog

      def initialize(opts={})
        setup_input_uri(opts)

        case @input_uri.scheme
        when 'udp'
          @syslog = UDPSocket.new()
          @syslog.connect(@input_uri.host, @input_uri.port)
        when 'tcp'
          @syslog = TCPSocket.new(@input_uri.host, @input_uri.port)
          @syslog.setsockopt( Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, 1 )
          @syslog.setsockopt( Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
        end

        unless @input_uri.path.empty?
          if @facility = @input_uri.path.split('/')[1]
            @facility = @facility.to_i
            unless @facility <= 23 && @facility >= 0
              raise Logglier::UnknownFacility.new(@facility.to_s)
            end
          end
        else
          @facility = 16
        end

        @format = opts[:format]
        @hostname = opts[:hostname] || Socket.gethostname.split('.').first
      end

      # Required by Logger::LogDevice
      def write(message)
        begin
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
        severity_value = case severity
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
        (@facility << 3) + severity_value
      end

      # Generate a syslog compat message
      # See RFC3164 4.1.1 - 4.1.3
      def formatter
        proc do |severity, datetime, progname, msg|
          processid=Process.pid
          message = "<#{pri(severity)}>#{datetime.strftime(datetime_format)} #{@hostname} "

          # Include process ID in progname/log tag - RFC3164 § 5.3
          if progname
            message << "#{progname}[#{processid}]: "
          else
            message << "#{$0}[#{processid}]: "
          end

          # Support logging JSON to Syslog
          if @format == :json && msg.is_a?(Hash)
            message << MultiJson.dump(msg)
          else
            message << massage_message(msg,severity,processid)
          end

          if @input_uri.scheme == 'tcp'
            message << "\r\n"
          end
          message
        end
      end

    end
  end
end
