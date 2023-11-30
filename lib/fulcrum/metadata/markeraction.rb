module UMPTG::Fulcrum::Metadata

  class MarkerAction < Action

  @@SELECTION_XPATH = <<-SXPATH
  .//*[
  local-name()='figcaption'
  ]
  SXPATH

    # Process an additional resource (Marker) action.
    def process(args = {})
      # Marker fragment. If there is a comment,
      # then use it value. Otherwise use the
      # element content.
      rnames = []
      if (@fragment.node.name == "figure" or @fragment.node.name == "span") and @fragment.node.key?("data-fulcrum-embed-filename")
        rnames << @fragment.node["data-fulcrum-embed-filename"]
      else
        comment = @fragment.node.xpath(".//comment()")
        comment << fragment.node if comment.empty?
        comment.each do |c|
          # Generally, additional resource references are expected
          # to use the markup:
          #     <p class="rb|rbi"><!-- resource_file_name.ext --></p>
          # But recently, Newgen has been using the markup
          #     <!-- <insert resource_file_name.ext> -->
          # So here we check for this case.
          r = c.text.match(/insert[ ]+([^\>]+)/)
          if r.nil?
            # Not Newgen markup.
            rn = c.text
          else
            # Appears to be Newgen markup.
            rn = r[1]
          end
          rnames << rn
        end
      end

      # Create a Marker object for each reference found.
      # Include the XML fragment node, the fragment identifier
      # (:name) and the resource name found within the markup.
      olist = []
      rnames.each do |r|
        next if r.nil? or r.strip.empty?
        if fragment.node.name == "figure"
          caption = @fragment.node.xpath(@@SELECTION_XPATH).first
          #puts "caption:#{caption}"
        end
        marker = MarkerObject.new(
                node: fragment.node,
                name: @properties[:name],
                resource_name: r,
                caption: caption
              )
        olist << marker
      end

      # Attach the list of Marker objects to this action
      # and set it status to COMPLETED.
      @object_list = olist
      @status = Action.COMPLETED
    end
  end
end
