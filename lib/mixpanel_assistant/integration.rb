module MixpanelAssistant
  module Integration
    extend ActiveSupport::Concern

    included do
      helper_method :mixpanel
      after_filter :store_mixpanel_if_redirecting
    end

    def mixpanel
      @mixpanel ||= MixpanelAssistant::Tracker.new(identity: current_user.try(:email))
    end

    def store_mixpanel_if_redirecting
      mixpanel.store! if status == 302
    end
  end
end