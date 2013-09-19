require "spec_helper"

describe Mixpal::Util do
  subject { described_class }

  describe ".hash_to_js_object_string" do
    it "converts a ruby hash to a string representation of a javascript object" do
      expect(subject.hash_to_js_object_string({key: "value", another: "more value"})).
        to eq "{\"key\": \"value\",\"another\": \"more value\"}"
    end

    it "leaves Booleans intact to be interpreted as JS Boolean" do
      expect(subject.hash_to_js_object_string({ is_cool: true })).
        to eq "{\"is_cool\": true}"
    end

    it "leaves Fixnums intact to be interpreted as JS Numbers" do
      expect(subject.hash_to_js_object_string({ age: 21 })).
        to eq "{\"age\": 21}"
    end
  end
end