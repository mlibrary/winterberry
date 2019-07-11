class MarkerActionFactory
  def self.create(args)
    action = args[:resource_action]

    case action['resource_action']
    when "embed"
      return EmbedMarkerAction.new(args)
    when "link"
      return LinkMarkerAction.new(args)
    when "none"
    else
      puts "Warning: invalid marker action #{action['resource_action']}"
    end
    return nil
  end
end