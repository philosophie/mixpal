class MockStorage
  attr_reader :data

  def initialize
    @data = {}
  end

  def write(key, value)
    data[key] = value
  end

  def read(key)
    data[key]
  end

  def delete(key)
    !!data.delete(key)
  end
end