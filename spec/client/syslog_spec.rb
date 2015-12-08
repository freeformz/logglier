require 'spec_helper'

describe Logglier::Client::Syslog do
  describe "PRI calculation conforms to RFC3164 4.1.1" do
    before do
      UDPSocket.stub(:new).and_return(mock("socket").as_null_object)
      TCPSocket.stub(:new).and_return(mock("Socket").as_null_object)
    end
    it "calculates a number with the lowest 3 bits representing the severity and the higher bits representing the facility" do
      client = described_class.new(:input_url => "udp://127.0.0.1:514/17")
      client.pri("WARN").should == (17 << 3) + 4
    end
  end

  describe '#formatter' do
    before do
      UDPSocket.stub(:new).and_return(mock('socket').as_null_object)
      TCPSocket.stub(:new).and_return(mock('Socket').as_null_object)
    end

    let(:client)      { described_class.new(input_url: 'udp://127.0.0.1:514/17') }
    let(:json_client) { described_class.new(input_url: 'udp://127.0.0.1:514/17', format: :json) }

    it 'includes the PID in the progname' do
      message = client.formatter.call 'INFO', Time.now, 'banana', 'test message'

      message.should match(/banana\[#{Process.pid}\]: /)
    end

    context 'when you pass a Hash' do
      it 'formats as JSON when the format is JSON' do
        message = json_client.formatter.call 'INFO', Time.now, 'banana', testing_json: true
        message.should match(/: {"testing_json":true}\z/)
      end

      it 'formats as a massaged message when the format is not JSON' do
        message = client.formatter.call 'INFO', Time.now, 'banana', testing_json: false
        message.should match(/: testing_json=false\z/)
      end
    end
  end
end
