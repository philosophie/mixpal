module MixpanelAssistant
  class Tracker
    attr_reader :events, :user_updates, :identity, :alias_user

    STORAGE_KEY = "mixpanel_assistant"
    class_attribute :storage
    self.storage = Rails.cache

    def initialize(args={})
      @events = []
      @user_updates = []

      restore!

      @identity = args[:identity]
    end

    def register_user(properties)
      @alias_user = true
      update_user(properties)
    end

    def update_user(properties)
      user_updates << MixpanelAssistant::User.new(properties)
    end

    def track(name, properties={})
      events << MixpanelAssistant::Event.new(name, properties)
    end

    def render
      "".tap do |html|
        html << "<script type=\"text/javascript\">"
        html << "mixpanel.alias(\"#{identity}\");" if alias_user
        html << events.map(&:render).join("")
        html << user_updates.map(&:render).join("")
        html << "mixpanel.identify(\"#{identity}\");" if identity
        html << "</script>"
      end.html_safe
    end

    def store!
      self.class.storage.write(STORAGE_KEY, to_store)
    end

    def restore!
      data = self.class.storage.read(STORAGE_KEY) || {}

      @alias_user = data[:alias_user]
      @identity = data[:identity]
      @events = data[:events].map { |e| MixpanelAssistant::Event.from_store(e) } if data[:events]
      @user_updates = data[:user_updates].map { |u| MixpanelAssistant::User.from_store(u) } if data[:user_updates]

      self.class.storage.delete(STORAGE_KEY)
    end

    def to_store
      {
        alias_user: @alias_user,
        identity: identity,
        events: events.map(&:to_store),
        user_updates: user_updates.map(&:to_store),
      }
    end
  end
end