require 'spec_helper'

describe Mixpal::Util do
  subject { described_class }

  describe '.hash_to_js_object_string' do
    it 'converts ruby hash to string representation of a javascript object' do
      hash = { key: 'value', another: 'more value' }
      expect(subject.hash_to_js_object_string(hash))
        .to eq '{"key": "value","another": "more value"}'
    end

    it 'leaves Booleans intact to be interpreted as JS Boolean' do
      expect(subject.hash_to_js_object_string(is_cool: true))
        .to eq '{"is_cool": true}'
    end

    it 'leaves Fixnums intact to be interpreted as JS Numbers' do
      expect(subject.hash_to_js_object_string(age: 21))
        .to eq '{"age": 21}'
    end

    it 'does not include keys with nil values' do
      expect(subject.hash_to_js_object_string(age: 21, gender: nil))
        .to eq '{"age": 21}'
    end

    it 'escapes double quotes in values' do
      expect(subject.hash_to_js_object_string(key: 'value "with" quotes'))
        .to eq '{"key": "value \"with\" quotes"}'
    end
  end
end
