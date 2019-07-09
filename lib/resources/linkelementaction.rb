class LinkElementAction < Action
  def process(args)
    metadata = args[:resource_metadata]
    link_resource(metadata)
  end

  def link_resource(metadata)
    embed_markup = link_markup(metadata, "View resource.")
    embed_markup = "<span class=\"enhanced-media-display\">#{embed_markup}</span>"

    embed_fragment = Nokogiri::XML.fragment(embed_markup)
    if embed_fragment == nil
      puts "Warning: error creating embed markup document"
      return
    end

    parent = @resource_node.parent
    caption = parent.xpath(".//*[local-name()='p' and @class='image_caption']")
    if caption == nil or caption.count == 0
      parent.add_child(embed_fragment)
    else
      c = caption[0]
      text_node = c.document.create_text_node(" ")
      c.add_child(text_node)
      c.add_child(embed_fragment)
    end

    #@resource_node.replace(embed_fragment)
  end
end