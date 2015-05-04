require 'mixpal/version'
require 'active_support/core_ext'

module Mixpal
  autoload :Util, 'mixpal/util'
  autoload :Tracker, 'mixpal/tracker'
  autoload :Event, 'mixpal/event'
  autoload :User, 'mixpal/user'
  autoload :Integration, 'mixpal/integration'

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :helper_module
  end
end
