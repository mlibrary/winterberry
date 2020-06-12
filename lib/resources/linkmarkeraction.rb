class LinkMarkerAction < Action
  def process()
    resource_action = @action_args[:resource_action]
    resource = @action_args[:resource]
    resource_node = resource.resource_node

    embed_markup = link_markup(resource_action, metadata['title'])
    embed_markup = "<div class=\"enhanced-media-display\">#{embed_markup}</div>"

    embed_fragment = Nokogiri::XML.fragment(embed_markup)
    if embed_fragment == nil
      @message = "Warning: error creating embed markup document"
      @status = Action.FAILED
    end

    resource_node.replace(embed_fragment)
    @status = Action.COMPLETED
  end
end