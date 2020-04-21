class ResourceMapResource
  attr_reader :name
  attr_accessor :properties

  def initialize(args = {})
    @name = args[:resource_name]
    @properties = args[:resource_properties]
  end
end