module Mixpal
  module Integration
    extend ActiveSupport::Concern

    included do
      helper_method :mixpanel
      after_filter :store_mixpanel_if_redirecting

      class_attribute :mixpanel_identity_data
      def self.mixpanel_identity(object_method, attribute_method)
        self.mixpanel_identity_data = {
          object_method: object_method,
          attribute_method: attribute_method,
        }
      end
    end

    def mixpanel
      @mixpanel ||= begin
        identity = if data = self.class.mixpanel_identity_data
          send(data[:object_method]).try(data[:attribute_method])
        end

        Mixpal::Tracker.new(identity: identity)
      end
    end

    private

    def store_mixpanel_if_redirecting
      mixpanel.store! if status == 302
    end
  end
end