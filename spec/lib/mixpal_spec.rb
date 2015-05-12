require 'spec_helper'

module TestModule
  def test_method
    true
  end
end

describe Mixpal do
  describe '#configure' do
    before do
      Mixpal.configure do |config|
        config.helper_module = TestModule 
      end
    end

    it 'allows a helper module to be set on Mixpal.configuration' do
      expect(Mixpal.configuration.helper_module).to be(TestModule)
    end
  end
end
