module UMPTG::Review

  class NormalizeMarkerAction < NormalizeAction

    def process(args = {})
      super(args)

      markup = "<figure class=\"enhanced-media-display\" data-fulcrum-embed-filename=\"#{@resource_path}\"/>"
      fragment = Nokogiri::XML.fragment(markup)

      reference_node.add_previous_sibling(fragment)
      add_info_msg("marker: \"#{@resource_path}\" converted marker.")

      if reference_node.parent.name == "p"
        # If parent of comment is a para then adding a figure
        # within the p will fail EPUBcheck. Try switching
        # p to a div.
        add_info_msg("Switching marker parent from #{reference_node.parent.name} to div.")
        reference_node.parent.name = "div"
      end

      reference_node.remove
      
      @status = NormalizeAction.NORMALIZED
    end
  end
end
