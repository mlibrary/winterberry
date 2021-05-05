module UMPTG::Fulcrum::Resources

  # Class that inserts a link markup to a resource fileset page.
  class LinkElementAction < Action
    def process()
      # Generate the link XML markup.
      link_markup = link_markup()
      link_markup = "<span class=\"enhanced-media-display\">#{link_markup}</span>"

      # Generate the link XML fragment.
      link_fragment = Nokogiri::XML.fragment(link_markup)
      if link_fragment == nil
        @message = "Warning: error creating embed markup document"
        @status = Action.FAILED
      end

      # Locate a caption, if possible. If the reference container
      # is a <p>, then search within the container parent.
      # If a caption is found, then append the link markup to the caption.
      # Otherwise, add the caption as last child to the container.
      text_node = reference_node.document.create_text_node(" ")
      reference_node.add_child(text_node)
      reference_node.add_child(link_fragment)
=begin
      container = reference_node.node_name == 'p' ? reference_node.parent : reference_node
      caption = Action.find_caption(container)

      if caption == nil or caption.count == 0
        container.add_child(link_fragment)
      else
        last_block = caption.xpath("./*[local-name()='p' and position()=last()]")
        c = (last_block.nil? or last_block.count == 0) ? caption.last : last_block.last
        text_node = c.document.create_text_node(" ")
        c.add_child(text_node)
        c.add_child(link_fragment)
      end
=end

      # Action completed.
      @status = Action.COMPLETED
    end
  end
end