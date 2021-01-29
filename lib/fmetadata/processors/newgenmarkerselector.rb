module UMPTG::FMetadata::Processors

  # Class selects references to additional resources (Markers)
  # found within an EPUB produced by vendor Newgen.
  class NewgenMarkerSelector < UMPTG::Fragment::Selector
    def select_element(name, attrs = [])
      return false
    end

    def select_comment(content)
      # Generally, additional resource references are expected
      # to use the markup:
      #     <p class="rb|rbi"><!-- resource_file_name.ext --></p>
      # But recently, Newgen has been using the markup
      #     <!-- <insert resource_file_name.ext> -->
      return content.match?(/\<insert[ ]+([^\>]+)\>/)
    end
  end
end
