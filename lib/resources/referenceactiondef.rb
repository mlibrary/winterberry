class ReferenceActionDef
  def initialize(args = {})
    @resource_map_action = args[:resource_map_action]
    @resource_metadata = args[:resource_metadata]
  end

  def reference_name
    return @resource_map_action.reference.name
  end

  def resource_name
    return @resource_map_action.resource.name unless @resource_map_action.resource.nil?
  end

  def action_str
    return @resource_map_action.type
  end

  def embed_markup
    return @resource_metadata['embed_code'] unless @resource_metadata.nil?
  end

  def resource_type
    return @resource_metadata.nil? ? "" : @resource_metadata['resource_type']
  end

  def link
    unless @resource_metadata.nil?
      link_data = @resource_metadata['link']
      link = link_data.match('^[^\(]+\(\"([^\"]+)\".*') {|m| m[1] }
      return link
    end
    return ""
  end

  def to_s
    return "#{action_str}: #{reference_name} => #{resource_name}"
  end
end