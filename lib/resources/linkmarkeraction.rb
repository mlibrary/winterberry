class LinkMarkerAction < Action
  def process()
    embed_markup = link_markup(metadata['title'])
    embed_markup = "<div class=\"enhanced-media-display\">#{embed_markup}</div>"

    embed_fragment = Nokogiri::XML.fragment(embed_markup)
    if embed_fragment == nil
      @message = "Warning: error creating embed markup document"
      @status = Action.FAILED
    end

    reference_container.replace(embed_fragment)
    @status = Action.COMPLETED
  end
end