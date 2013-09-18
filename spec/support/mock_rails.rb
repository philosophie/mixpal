require File.expand_path("spec/support/mock_storage")

class MockRails
  class_attribute :cache
  self.cache = MockStorage.new
end