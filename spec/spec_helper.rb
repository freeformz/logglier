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

shared_examples_for "a logglier enhanced ActiveSupport::Logger instance" do
  context "#add" do
    context "with a string" do
      it "should send a message via the logdev" do
        subject.logdev.dev.should_receive(:write).with(/severity=WARN, foo/)
        subject.add(ActiveSupport::Logger::WARN) { 'foo' }
      end
    end

    context "with a hash" do
      it "should send a message via the logdev" do
        subject.logdev.dev.should_receive(:write).with(/severity=WARN/)
        subject.logdev.dev.should_receive(:write).with(/foo=bar/)
        subject.logdev.dev.should_receive(:write).with(/man=pants/)
        # The following is equiv to:
        # subject.warn :foo => :bar, :man => :pants
        subject.add(ActiveSupport::Logger::WARN) { {:foo => :bar, :man => :pants} }
        subject.add(ActiveSupport::Logger::WARN) { {:foo => :bar, :man => :pants} }
        subject.add(ActiveSupport::Logger::WARN) { {:foo => :bar, :man => :pants} }
      end
    end
  end
end
