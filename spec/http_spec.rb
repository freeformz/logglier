require 'spec_helper'

describe 'HTTP' do
  before do
    @http = mock('Net::HTTP')
    @http.stub!(:start)
    @http.stub!(:read_timeout=)
    @http.stub!(:open_timeout=)
    Net::HTTP.stub!(:new).and_return(@http)
    @failsafe = StringIO.new
    @proxy = Logglier::Client::HTTP::NetHTTPProxy.new(URI.parse('http://localhost:9292'), :failsafe => @failsafe)
    @proxy.stub(:sleep)
  end

  it "retries after connection is reset" do
    @http.should_receive(:request_post).and_raise Errno::ECONNRESET
    @http.should_receive(:request_post)
    @proxy.deliver('message')
  end

  it "defaults its failsafe to $stderr" do
    proxy = Logglier::Client::HTTP::NetHTTPProxy.new(URI.parse('http://localhost:9292'))
    proxy.failsafe.should == $stderr
  end

  describe "error handling" do
    Logglier::Client::HTTP::NetHTTPProxy::RETRY_EXCEPTIONS.each do |error|
      context "for #{error}" do
        context "with total failure" do
          before do
            @http.should_receive(:request_post).exactly(4).times.and_raise error
          end

          it "retries 3 times then fails" do
            @proxy.deliver('message')
          end

          it "logs messages to the failsafe along the way" do
            @proxy.deliver('message')

            @failsafe.rewind
            lines = @failsafe.readlines
            lines.size.should == 4
            lines[0..2].each {|l| l.should =~ /^WARNING/ }
            lines.last.should =~ /^ERROR/
          end
        end

        context "if things start working again" do
          before do
            @http.should_receive(:request_post).exactly(3).times.and_raise error
            @http.should_receive(:request_post)
          end

          it "is successful if things start working again" do
            @proxy.deliver('message')
          end

          it "logs messages to the failsafe along the way" do
            @proxy.deliver('message')

            @failsafe.rewind
            lines = @failsafe.readlines
            lines.size.should == 3
            lines[0..2].each {|l| l.should =~ /^WARNING/ }
          end
        end
      end
    end

    context "for an unknown error" do
      it "logs a message" do
        error = Class.new(StandardError)

        @http.should_receive(:request_post).and_raise error
        @proxy.deliver('message')

        @failsafe.rewind
        lines = @failsafe.readlines
        lines.size.should == 1
        lines.first.should =~ /^ERROR/
      end
    end
  end

  describe "json format" do
  end
end
