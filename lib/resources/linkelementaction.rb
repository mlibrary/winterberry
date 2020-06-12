class LinkElementAction < Action
  def process()
    resource_action = @action_args[:resource_action]
    resource = @action_args[:resource]
    resource_node = resource.resource_node

    link_markup = link_markup(resource_action, "View resource.")
    link_markup = "<span class=\"enhanced-media-display\">#{link_markup}</span>"

    link_fragment = Nokogiri::XML.fragment(link_markup)
    if link_fragment == nil
      @message = "Warning: error creating embed markup document"
      @status = Action.FAILED
    end

    container = resource_node.node_name == 'p' ? resource_node.parent : resource_node
    caption = Action.find_caption(container)
    if caption == nil or caption.count == 0
      container.add_child(link_fragment)
    else
      last_block = caption.xpath("./*[local-name()='p' and position()=last()]")
      c = last_block.nil? ? caption.last : last_block.last
      text_node = c.document.create_text_node(" ")
      c.add_child(text_node)
      c.add_child(link_fragment)
    end

    @status = Action.COMPLETED
  end
end