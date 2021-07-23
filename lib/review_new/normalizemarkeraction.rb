module UMPTG::Review

  class NormalizeMarkerAction < Action

    def process(args = {})
      super(args)

      # Return the nodes that reference resources.
      # For marker callouts, this should be within
      # a XML comment, but not always the case.
      # NOTE: either display warning if no comment,
      # or just use the node content?
      node_list = reference_node.xpath(".//comment()")
      node_list = [ reference_node ] if node_list.nil? or node_list.empty?
      reference_action_list = []
      node_list.each do |node|
        path = node.text.strip

        #path = path.match(/insert[ ]+([^\>]+)/)[1]
        # Generally, additional resource references are expected
        # to use the markup:
        #     <p class="rb|rbi"><!-- resource_file_name.ext --></p>
        # But recently, Newgen has been using the markup
        #     <!-- <insert resource_file_name.ext> -->
        # So here we check for this case.
        r = path.match(/insert[ ]+([^\>]+)/)
        unless r.nil?
          # Appears to be Newgen markup.
          path = r[1]
        end

        markup = "<div data-embed-filename=\"#{path}\"/>"
        fragment = Nokogiri::XML.fragment(markup)

        reference_node.add_previous_sibling(fragment)
        add_info_msg("Marker: #{path} converted marker.")
      end
      reference_node.remove
      
      @status = Action.COMPLETED
    end
  end
end
