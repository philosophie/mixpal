module MixpanelAssistant
  class Event
    attr_reader :name, :properties

    def initialize(name, properties)
      @name = name
      @properties = properties
    end

    def render
      js_object = MixpanelAssistant::Util.hash_to_js_object_string(properties)
      "mixpanel.track(\"#{name}\", #{js_object});".html_safe
    end

    def to_store
      {
        name: name,
        properties: properties,
      }
    end

    def self.from_store(data)
      new(data[:name], data[:properties])
    end
  end
end