class MarkerActionFactory
  def self.create(args)
    resource_action = args[:resource_action]

    case resource_action.action_str
    when "embed"
      return EmbedMarkerAction.new(args)
    when "link"
      return LinkMarkerAction.new(args)
    when "none"
    else
      puts "Warning: invalid marker action #{resource_action.action_str}"
    end
    return nil
  end
end