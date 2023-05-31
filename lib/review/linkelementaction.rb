module UMPTG::Review

  # Class that inserts resource embed viewer markup into
  # XML content (image, video, audio).
  class LinkElementAction < EmbedAction

    def process()
      resource_path = @properties[:resource_path]
      link_markup = @properties[:link_fragment]

      # Generate the link XML fragment.
      link_fragment = Nokogiri::XML.fragment(link_markup)
      if link_fragment == nil
        @message = "Warning: error creating embed markup document"
        @status = Action.FAILED
      end

      reference_node.children.each {|n| n.remove }
      reference_node.add_child(link_fragment)

      reference_node.remove_attribute("data-fulcrum-embed-filename") \
          if reference_node.has_attribute?("data-fulcrum-embed-filename")

      add_info_msg("link resource for #{resource_path}")

      # Action completed.
      @status = NormalizeAction.NORMALIZED
    end
  end
end
