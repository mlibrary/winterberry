class EmbedElementAction < Action
  def process()
    metadata = @action_args[:resource_metadata]
    resource = @action_args[:resource]
    img_node = @action_args[:resource_img]
    resource_node = resource.resource_node

    if resource_node.node_name == "p"
      resource_node.node_name = "div"
    end

    embed_markup = metadata['embed_code']
    if embed_markup == nil or embed_markup.strip.empty?
      puts "Warning: no embed markup for resource node #{@resource_node}"
      return
    end

    embed_fragment = Nokogiri::XML.fragment(embed_markup)
    if embed_fragment == nil
      puts "Warning: error creating embed markup document"
      return
    end

    default_container = img_node.document.create_element("div", :class => "default-media-display")
    img_node.add_next_sibling(default_container)
    default_container.add_child(img_node)

    embed_container = img_node.document.create_element("div", :class => "enhanced-media-display")
    embed_container.add_child(embed_fragment)

    default_container.add_next_sibling(embed_container)
  end
end