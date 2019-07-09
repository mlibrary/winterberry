class LinkMarkerAction < Action
  def process(args)
    metadata = args[:resource_metadata]
    link_resource(metadata)
  end

  def link_resource(metadata)
    embed_markup = link_markup(metadata, metadata['title'])
    embed_markup = "<div class=\"enhanced-media-display\">#{embed_markup}</div>"

    embed_fragment = Nokogiri::XML.fragment(embed_markup)
    if embed_fragment == nil
      puts "Warning: error creating embed markup document"
      return
    end

    @resource_node.replace(embed_fragment)
  end
end