class ElementActionFactory
  def self.create(args)
    resource_action = args[:resource_action]
    action_str = resource_action.action_str

    case action_str
    when "embed"
      resource_type = resource_action.resource_type
      return resource_type == 'interactive map' ? \
              EmbedMapAction.new(args) : \
              EmbedElementAction.new(args)
    when "link"
      return LinkElementAction.new(args)
    when "remove"
      return RemoveElementAction.new(args)
    when "none"
      return NoneAction.new(args)
    else
      puts "Warning: invalid element action #{action}"
    end
    return nil
  end
end