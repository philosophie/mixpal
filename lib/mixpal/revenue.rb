module Mixpal
  class Revenue
    attr_reader :amount, :properties

    def initialize(amount, properties)
      @amount = amount
      @properties = properties
    end

    def render
      args = "#{amount}, #{properties_as_js_object_for_mixpanel}"
      "mixpanel.people.track_charge(#{args});".html_safe
    end

    def to_store
      {
        'amount' => amount,
        'properties' => properties
      }
    end

    def self.from_store(data)
      new(data['amount'], data['properties'])
    end

    private

    def properties_as_js_object_for_mixpanel
      Mixpal::Util.hash_to_js_object_string(properties)
    end
  end
end
