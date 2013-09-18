require "spec_helper"

describe MixpanelAssistant::User do
  let(:properties) { { random_property: "Hansel", another_random_one: "So Hot Right Now" } }
  let(:subject) { described_class.new(properties) }

  describe "#render" do
    it "delegates to Util for js_object composition" do
      MixpanelAssistant::Util.should_receive(:hash_to_js_object_string).with(properties)
      subject.render
    end

    it "outputs a call to people.set" do
      js_object = MixpanelAssistant::Util.hash_to_js_object_string(properties)
      expect(subject.render).to eq "mixpanel.people.set(#{js_object});"
    end

    it "outputs an html safe string" do
      expect(subject.render).to be_html_safe
    end

    context "with Mixpanel special properties" do
      let(:properties) do
        {
          name: "Nick Giancola",
          email: "nick@gophilosophie.com",
          created_at: Time.now,
          random_property: "Hansel",
        }
      end

      it "converts name => $name" do
        expect(subject.render).to include "\"$name\""
        expect(subject.render).not_to include "\"name\""
      end

      it "converts email => $email" do
        expect(subject.render).to include "\"$email\""
        expect(subject.render).not_to include "\"email\""
      end

      it "converts created_at => $created" do
        expect(subject.render).to include "\"$created\""
        expect(subject.render).not_to include "\"created_at\""
      end

      it "leaves other properties untouched" do
        expect(subject.render).to include "\"random_property\""
        expect(subject.render).not_to include "\"$random_property\""
      end
    end
  end

  describe "#to_store" do
    it "returns a hash with its data" do
      expect(subject.to_store).to eq(
        properties: properties,
      )
    end
  end

  describe "#from_store" do
    let(:result) { described_class.from_store(properties: properties) }

    it "instantiates a new instance" do
      expect(result).to be_an_instance_of(described_class)
    end

    it "sets its properties from the data" do
      expect(result.properties).to eq properties
    end
  end
end