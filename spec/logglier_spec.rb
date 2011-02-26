describe Logglier do

  subject { Logglier.new('https://localhost') }

  it { should be_an_instance_of Logger }
end
