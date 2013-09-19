require "spec_helper"

describe Mixpal::Event do
  let(:name) { "Event 1" }
  let(:properties) { { title: "Awesome Product" } }
  subject { described_class.new(name, properties) }

  describe "#render" do
    it "delegates to Util for js_object composition" do
      Mixpal::Util.should_receive(:hash_to_js_object_string).with(properties)
      subject.render
    end

    it "outputs a call to track" do
      js_object = Mixpal::Util.hash_to_js_object_string(properties)
      expect(subject.render).to eq "mixpanel.track(\"#{name}\", #{js_object});"
    end

    it "outputs an html safe string" do
      expect(subject.render).to be_html_safe
    end
  end

  describe "#to_store" do
    it "returns a hash with its data" do
      expect(subject.to_store).to eq(
        name: name,
        properties: properties,
      )
    end
  end

  describe ".from_store" do
    let(:result) { described_class.from_store(name: name, properties: properties) }

    it "instantiates a new instance" do
      expect(result).to be_an_instance_of(described_class)
    end

    it "sets its name from the data" do
      expect(result.name).to eq name
    end

    it "sets its properties from the data" do
      expect(result.properties).to eq properties
    end
  end
end