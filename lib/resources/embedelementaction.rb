class EmbedElementAction < Action
  def process(args)
    metadata = args[:resource_metadata]
    embed_resource(metadata)
  end

  def embed_resource(metadata)

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

    default_container = @resource_node.document.create_element("div", :class => "default-media-display")
    @resource_node.add_next_sibling(default_container)
    default_container.add_child(@resource_node)

    embed_container = @resource_node.document.create_element("div", :class => "enhanced-media-display")
    embed_container.add_child(embed_fragment)

    default_container.add_next_sibling(embed_container)
  end
end