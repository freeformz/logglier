require 'spec_helper'

describe Logglier do
  before do
    Logglier::Client::HTTP::NetHTTPProxy.stub(:new) { MockNetHTTPProxy.new }
  end

  context "HTTPS" do

    context "w/o any options" do
      subject { new_logglier('https://localhost') }

      it { should be_an_instance_of Logger }
      its('logdev.dev') { should be_an_instance_of Logglier::Client::HTTP }

      it_should_behave_like "a logglier enhanced Logger instance"
    end

    context "w/threaded option" do
      subject { new_logglier('https://localhost', :threaded => true) }

      it { should be_an_instance_of Logger }
      its('logdev.dev') { should be_an_instance_of Logglier::Client::HTTP }

      it_should_behave_like "a logglier enhanced Logger instance"
    end

  end

  context "Syslog TCP" do
    before { TCPSocket.stub(:new) { MockTCPSocket.new } }

    subject { new_logglier('tcp://localhost:12345') }

    it { should be_an_instance_of Logger }
    its('logdev.dev') { should be_an_instance_of Logglier::Client::Syslog }

    it_should_behave_like "a logglier enhanced Logger instance"

  end

  context "Syslog UDP" do
    subject { new_logglier('udp://localhost:12345') }

    it { should be_an_instance_of Logger }
    its('logdev.dev') { should be_an_instance_of Logglier::Client::Syslog }

    it_should_behave_like "a logglier enhanced Logger instance"

  end
end
