require 'spec_helper'

describe Logglier::Client::HTTP::DeliveryThread do
  before do
    @mock_http = MockNetHTTPProxy.new
    Logglier::Client::HTTP::NetHTTPProxy.stub(:new) { @mock_http }
  end

  subject { described_class.new(URI.parse('http://localhost')) }

  it "should deliver the message" do
    @mock_http.should_receive(:deliver).with("test")
    subject.deliver('test')

    #Signal the thread it's going to exit
    subject.exit!

    #Wait for it to exit
    subject.join
  end
end

describe Logglier::Client::HTTP::DeliveryThreadManager do
  before do
    @mock_http = MockNetHTTPProxy.new
    Logglier::Client::HTTP::NetHTTPProxy.stub(:new) { @mock_http }
  end

  subject { described_class.new(URI.parse('http://localhost')) }

  it "should instantiate a delivery_thread" do
    Logglier::Client::HTTP::DeliveryThread.should_receive(:new).once
    subject
  end

  it "should deliver messages via delivery_thread" do
    @mock_thread = Object.new
    @mock_thread.stub(:alive?) { true }
    @mock_thread.should_receive(:deliver).once.with('foo')
    Logglier::Client::HTTP::DeliveryThread.should_receive(:new).once.and_return(@mock_thread)

    subject.deliver('foo')
  end

  it "should respawn a dead delivery_thread" do
    @first_thread = subject.instance_variable_get(:@thread)
    @first_thread.should_receive(:deliver).once.with('first')

    subject.deliver('first')

    @first_thread.kill

    subject.deliver('force respawn')

    @second_thread = subject.instance_variable_get(:@thread)
    @second_thread.should_not eql(@first_thread)
    @second_thread.should_receive(:deliver).once.with('second')

    subject.deliver('second')
  end
end
