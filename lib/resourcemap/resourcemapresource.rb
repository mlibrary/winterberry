class ResourceMapResource
  attr_reader :name, :properties

  def initialize(args = {})
    @name = args[:resource_name]
    @properties = args[:resource_properties]
  end
end