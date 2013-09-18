module MixpanelAssistant
  class User
    attr_reader :properties

    def initialize(properties)
      @properties = properties
    end

    def render
      "mixpanel.people.set(#{properties_as_js_object_for_mixpanel});".html_safe
    end

    def to_store
      {
        properties: properties,
      }
    end

    def self.from_store(data)
      new(data[:properties])
    end

    private

    def properties_as_js_object_for_mixpanel
      MixpanelAssistant::Util.hash_to_js_object_string(properties_for_mixpanel)
    end

    # Isolate special properties and rename their keys to align with
    # Mixpanel's naming.
    def properties_for_mixpanel
      Hash[properties.map {|k, v| [mixpanel_special_properties_map[k] || k, v] }]
    end

    def mixpanel_special_properties_map
      {
        name: "$name",
        email: "$email",
        created_at: "$created",
      }.with_indifferent_access
    end
  end
end