require 'mixpal/version'
require 'active_support'
require 'active_support/core_ext'

module Mixpal
  autoload :Util, 'mixpal/util'
  autoload :Tracker, 'mixpal/tracker'
  autoload :Event, 'mixpal/event'
  autoload :User, 'mixpal/user'
  autoload :Integration, 'mixpal/integration'

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield(self.configuration)
  end

  class Configuration
    attr_writer :helper_module

    def helper_module
      @helper_module ||= Module.new 
    end
  end
end
