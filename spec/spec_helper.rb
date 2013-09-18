require "bundler"
Bundler.require

require "mixpanel_assistant"

Dir["./spec/support/**/*.rb"].each {|f| require f }

Rails = MockRails

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end