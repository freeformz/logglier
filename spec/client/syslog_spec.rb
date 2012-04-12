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
end