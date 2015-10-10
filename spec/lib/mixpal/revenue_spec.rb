require 'spec_helper'

describe Mixpal::Revenue do
  let(:properties) do
    {
      sku: 'SKU-1010'
    }
  end

  let(:amount) { 50 }

  let(:subject) { described_class.new(amount, properties) }

  describe '#render' do
    it 'delegates to Util for js_object composition' do
      Mixpal::Util.should_receive(:hash_to_js_object_string).with(properties)
      subject.render
    end

    it 'outputs a call to people.track_charge' do
      js_object = Mixpal::Util.hash_to_js_object_string(properties)
      expect(subject.render)
        .to eq "mixpanel.people.track_charge(#{amount}, #{js_object});"
    end

    it 'outputs an html safe string' do
      expect(subject.render).to be_html_safe
    end
  end

  describe '#to_store' do
    it 'returns a hash with its data' do
      expect(subject.to_store).to eq(
        'amount' => amount,
        'properties' => properties
      )
    end
  end

  describe '#from_store' do
    let(:result) do
      described_class.from_store(
        'amount' => amount,
        'properties' => properties
      )
    end

    it 'instantiates a new instance' do
      expect(result).to be_an_instance_of(described_class)
    end

    it 'sets its amount from the data' do
      expect(result.amount).to eq amount
    end

    it 'sets its properties from the data' do
      expect(result.properties).to eq properties
    end
  end
end
