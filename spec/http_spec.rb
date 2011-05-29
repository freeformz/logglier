require 'spec_helper'

describe 'HTTP' do
  before do
    @http = mock('Net::HTTP')
    @http.stub!(:start)
    @http.stub!(:read_timeout=)
    @http.stub!(:open_timeout=)
    Net::HTTP.stub!(:new).and_return(@http)
    @proxy = Logglier::Client::HTTP::NetHTTPProxy.new(URI.parse('http://localhost:9292'))
  end

  it "retries after connection is reset" do
    @http.should_receive(:request_post).and_raise Errno::ECONNRESET
    @http.should_receive(:request_post)
    @proxy.deliver('message')
  end

  it "fails for other errors" do
    @http.should_receive(:request_post).once.and_raise EOFError
    @proxy.deliver('message')
  end
end