class LinkMarkerAction < Action
  def process()
    metadata = @action_args[:resource_metadata]
    resource = @action_args[:resource]
    resource_node = resource.resource_node

    embed_markup = link_markup(metadata, metadata['title'])
    embed_markup = "<div class=\"enhanced-media-display\">#{embed_markup}</div>"

    embed_fragment = Nokogiri::XML.fragment(embed_markup)
    if embed_fragment == nil
      puts "Warning: error creating embed markup document"
      return
    end

    resource_node.replace(embed_fragment)
  end
end