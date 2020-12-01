module UMPTG::EPUB::Processors

  # Class selects markers found within an EPUB.
  class NewgenMarkerSelector < UMPTG::Fragment::Selector
    def select_element(name, attrs = [])
      return false
    end

    def select_comment(content)
      return content.match?(/\<insert[ ]+([^\>]+)\>/)
    end
  end
end
