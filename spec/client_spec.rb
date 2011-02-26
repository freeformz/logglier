require 'spec_helper'

describe Logglier::Client do

  context "#new" do

    context "w/o any params" do

      it "should raise an error" do
        expect { Logglier::Client.new() }.to raise_error Logglier::InputURLRequired
      end

    end

    context "a single string param" do

      context "that is a valid uri" do

        it "should return and instance of itself" do
          log = Logglier::Client.new('http://localhost')
          log.should be_an_instance_of Logglier::Client
        end

      end

      context "that is NOT a valid uri" do

        it "should raise an error" do
          expect { Logglier::Client.new('f://://://') }.to raise_error Logglier::InputURLRequired
        end

      end

    end

  end

  context "#write" do
    before do
      @log = Logglier::Client.new('https://localhost')
      @log.http.stub(:start)
    end

    context "with a message" do

      it "should start a http call" do
        @log.http.should_receive(:start)
        @log.write('msg')
      end

    end
  end
end
