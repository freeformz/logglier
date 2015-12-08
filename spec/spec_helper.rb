$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'logglier'
require 'stringio'

module LoggerHacks
  def logdev
    @logdev
  end
end

RSpec.configure do |config|
  config.color_enabled = config.tty = true
  config.add_formatter('documentation')

  config.before(:each) do
  end

  class MockTCPSocket
    def initialize(*args); end
    def setsockopt(*args); end
    def send(*args); end
  end

  class MockNetHTTPProxy
    def initialize(*args); end
    def deliver(*args); end
  end

  def new_logglier(url,opts={})
    log = Logglier.new(url,opts)
    log.extend(LoggerHacks)
  end

end

shared_examples_for "a logglier enhanced Logger instance" do
  context "#add" do
    context "with a string" do
      it "should send a message via the logdev" do
        if subject.logdev.dev.is_a?(Logglier::Client::Syslog)
          subject.logdev.dev.should_receive(:write).with(/foo/)
        else
          subject.logdev.dev.should_receive(:write).with(/severity=WARN, foo/)
        end

        subject.add(Logger::WARN) { 'foo' }
      end
    end

    context "with a hash" do
      it "should send a message via the logdev" do
        # expect count is the number of times we need to
        # repeat the log message to test all of the possibilities
        if subject.logdev.dev.is_a?(Logglier::Client::Syslog)
          expect_count = 2
        else
          expect_count = 3
          subject.logdev.dev.should_receive(:write).with(/severity=WARN/)
        end

        expect(subject.logdev.dev).to receive(:write).with(/foo=bar/)
        expect(subject.logdev.dev).to receive(:write).with(/man=pants/)

        # The following is equiv to:
        # subject.warn :foo => :bar, :man => :pants
        expect_count.times do
          subject.add(Logger::WARN) { {:foo => :bar, :man => :pants} }
        end
      end
    end
  end
end
