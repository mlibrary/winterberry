module UMPTG::Fulcrum::Resources

  # Class defines the Action for a specific resource reference.
  # It contains the type of action (embed|link) and the Fulcrum
  # metadata for the resource.
  class ReferenceActionDef < UMPTG::Object
    def initialize(args = {})
      super(args)

      @resource_map_action = @properties[:resource_map_action]
      @resource_metadata = @properties[:resource_metadata]
    end

    # Resource reference name.
    def reference_name
      return @resource_map_action.reference.name
    end

    # Resource name.
    def resource_name
      return @resource_map_action.resource.name unless @resource_map_action.resource.nil?
    end

    # String for the assigned action type.
    def action_str
      return @resource_map_action.type
    end

    # Resource embed markup.
    def embed_markup
      return @resource_metadata['embed_code'] unless @resource_metadata.nil?
    end

    # Resource type.
    def resource_type
      return @resource_metadata.nil? ? "" : @resource_metadata['resource_type']
    end

    # Resource Fulcrum link path.
    def link
      unless @resource_metadata.nil?
        link_data = @resource_metadata['link']
        link = link_data.match('^[^\(]+\(\"([^\"]+)\".*') {|m| m[1] }
        return link
      end
      return ""
    end

    # Resource alternative text.
    def alt_text
      return @resource_metadata['alternative_text'] unless @resource_metadata.nil?
    end

    # Generate a string for this definition.
    def to_s
      return "#{action_str}: #{reference_name} => #{resource_name}"
    end
  end
end
