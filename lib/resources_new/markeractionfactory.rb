class MarkerActionFactory
  def self.create(resource, action)
    case action['resource_action']
    when "embed"
      return EmbedMarkerAction.new(resource)
    when "link"
      return LinkMarkerAction.new(resource)
    else
      puts "Warning: invalid marker action #{action}"
    end
    return nil
  end
end