class ResourceMapAction

  attr_reader :reference_id, :resource_id, :reference, :resource
  attr_accessor :type

  def initialize(args = {})
    @reference_id = args[:reference_id]
    @reference = args[:reference]
    @resource_id = args[:resource_id]
    @resource = args[:resource]
    @type = args[:type]
  end

  def resource_name
    return @resource.name
  end

  def resource_properties
    return @resource.properties
  end
end
