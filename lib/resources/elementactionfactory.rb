class ElementActionFactory
  def self.create(args)
    action = args[:resource_action]

    action_str = action['resource_action'].downcase
    if action_str == 'default'
      resource = args[:resource]
      action_str = resource.default_action['resource_action']
    end

    case action_str
    when "embed"
      return EmbedElementAction.new(args)
    when "link"
      return LinkElementAction.new(args)
    when "remove"
      return RemoveElementAction.new(args)
    else
      puts "Warning: invalid element action #{action}"
    end
    return nil
  end
end