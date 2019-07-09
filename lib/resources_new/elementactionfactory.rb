class ElementActionFactory
  def self.create(resource, action)
    case action['resource_action']
    when "embed"
      return EmbedElementAction.new(resource)
    when "link"
      return LinkElementAction.new(resource)
    when "remove"
      return RemoveElementAction.new(resource)
    else
      puts "Warning: invalid element action #{action}"
    end
    return nil
  end
end