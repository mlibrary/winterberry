module UMPTG::Review

  class NormalizeMarkerAction < NormalizeAction

    def process(args = {})
      super(args)

      # Review: Hyrax replaces spaces in file names with underscores.
      # Recommendation is that resource file names should not contain
      # spaces. But it may be awhile before authors and vendors
      # will implement this.
      #rp = @resource_path.gsub(/[ ]+/,'_')
      #rp = @resource_path
      rp = File.basename(@resource_path)

      reference_container = reference_node.xpath("./ancestor::*[local-name()='figure'][1]").first
      if reference_container.nil?
        #markup = "<figure class=\"enhanced-media-display\" data-fulcrum-embed-filename=\"#{rp}\"/>"
        markup = "<figure style=\"display:none\" data-fulcrum-embed-filename=\"#{rp}\"><figcaption/></figure>"
        fragment = Nokogiri::XML.fragment(markup)

        reference_node.add_previous_sibling(fragment)
      else
        reference_container["data-fulcrum-embed-filename"] = rp
        style = reference_container["style"]
        style = style.nil? ? "display:none" : style + ";display:none"
        reference_container["style"] = style
      end

      add_info_msg("marker: converted marker \"#{@resource_path}\".") if rp == @resource_path
      add_info_msg("marker: converted marker, path converted \"#{@resource_path}\" to \"#{rp}\".") unless rp == @resource_path

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
