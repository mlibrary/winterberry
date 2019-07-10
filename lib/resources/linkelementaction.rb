class LinkElementAction < Action
  def process(args)
    metadata = args[:resource_metadata]
    link_resource(metadata)
  end

  def link_resource(metadata)
    link_markup = link_markup(metadata, "View resource.")
    link_markup = "<span class=\"enhanced-media-display\">#{link_markup}</span>"

    link_fragment = Nokogiri::XML.fragment(link_markup)
    if link_fragment == nil
      puts "Warning: error creating embed markup document"
      return
    end

    parent = @resource_node.parent
    caption = parent.xpath(".//*[local-name()='p' and (@class='image_caption' or @class='figh')]")
    if caption == nil or caption.count == 0
      parent.add_child(link_fragment)
    else
      c = caption[0]
      text_node = c.document.create_text_node(" ")
      c.add_child(text_node)
      c.add_child(link_fragment)
    end
  end
end