module UMPTG::Fulcrum::Resources

  # Class that inserts a link markup to a resource fileset page.
  class LinkMarkerAction < Action
    def process()
      # Generate the link XML markup.
      embed_markup = link_markup(metadata['title'])
      embed_markup = "<div class=\"enhanced-media-display\">#{embed_markup}</div>"

      # Generate the link XML fragment.
      embed_fragment = Nokogiri::XML.fragment(embed_markup)
      if embed_fragment == nil
        @message = "Warning: error creating embed markup document"
        @status = Action.FAILED
      end

      # Replace the entire reference container with the link markup.
      reference_container.replace(embed_fragment)

      # Action completed.
      @status = Action.COMPLETED
    end
  end
end
