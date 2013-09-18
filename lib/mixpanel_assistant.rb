require "mixpanel_assistant/version"
require "active_support/core_ext"

module MixpanelAssistant
  autoload :Util, "mixpanel_assistant/util"
  autoload :Tracker, "mixpanel_assistant/tracker"
  autoload :Event, "mixpanel_assistant/event"
  autoload :User, "mixpanel_assistant/user"
  autoload :Integration, "mixpanel_assistant/integration"
end
