module UMPTG::Fulcrum::Metadata::Processors

  # Class selects references to resources found within
  # an EPUB produced by vendor Rekihaku.
  class ApexContainerSelector < UMPTG::Fragment::Selector
    def select_element(name, attrs = [])
      # Select <figure> or <img> or a <div class="fig">.
      case name
      when "div"
        attrs_map = attrs.to_h
        if attrs_map.key?("class")
          attrs_map["class"].strip.split(' ').each do |attrval|
            return true if attrval == "fig"
          end
        end
      when "figure", "img"
        return true
      end
      return false
    end
  end
end
