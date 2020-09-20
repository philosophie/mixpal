module Mixpal
  module Integration
    extend ActiveSupport::Concern

    included do
      helper_method :mixpanel
      if Rails::VERSION::MAJOR >= 4
        after_action :store_mixpanel_if_redirecting
      else
        after_filter :store_mixpanel_if_redirecting
      end

      class_attribute :mixpanel_identity_data
      def self.mixpanel_identity(object_method, attribute_method)
        self.mixpanel_identity_data = {
          object_method: object_method,
          attribute_method: attribute_method
        }
      end
    end

    def mixpanel
      @mixpanel ||= begin
        identity = if (data = self.class.mixpanel_identity_data)
                     send(data[:object_method]).try(data[:attribute_method])
                   end

        Mixpal::Tracker.new(identity: identity).tap { |t| t.restore!(session) }
      end
    end

    private

    def store_mixpanel_if_redirecting
      mixpanel.store!(session) if status == 302
    end
  end
end
