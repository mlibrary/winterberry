module UMPTG::Fulcrum::Resources

  # Class that inserts a link markup to a resource fileset page.
  class LinkMarkerAction < Action
    def process()
      # Generate the link XML markup.
      resource_metadata = @reference_action_def.resource_metadata
      if reference_node.name == "span"
        content = reference_node.content.strip.empty? ? \
            resource_metadata['title'] : reference_node.content
        embed_markup = link_markup(content)
        #embed_markup = "<span class=\"enhanced-media-display\">#{embed_markup}</span>"
        embed_fragment = Nokogiri::XML.fragment(embed_markup)
        if embed_fragment == nil
          @message = "Warning: error creating embed markup document"
          @status = Action.FAILED
        end
        #reference_node.append_class("default-media-display")
        reference_node.content = ""
        reference_node.add_child(embed_fragment)
      else
        embed_markup = link_markup(resource_metadata['title'])
        embed_markup = "<div class=\"enhanced-media-display\">#{embed_markup}</div>"

        # Generate the link XML fragment.
        embed_fragment = Nokogiri::XML.fragment(embed_markup)
        if embed_fragment == nil
          @message = "Warning: error creating embed markup document"
          @status = Action.FAILED
        end

        # Wrap the current resource XML markup with a container
        # that allows it to be visible when not in the Fulcrum reader.
        def_container = default_container
        reference_node.add_next_sibling(def_container)
        def_container.add_child(reference_node)

        def_container.add_next_sibling(embed_fragment)

        # Replace the entire reference container with the link markup.
        #reference_container.replace(embed_fragment)
      end

      # Action completed.
      @status = Action.COMPLETED
    end
  end
end
