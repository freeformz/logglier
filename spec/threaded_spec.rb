describe Logglier::Client::HTTP::DeliveryThread do

  subject { described_class.new(URI.parse('http://localhost')) }

  before do
    subject.stub(:deliver)
  end

  it "should" do
    subject.should_receive(:deliver).with("test")
    subject.push('test')

    #Signal the thread it's going to exit
    subject.exit!

    #Wait for it to exit
    subject.join
  end
end
