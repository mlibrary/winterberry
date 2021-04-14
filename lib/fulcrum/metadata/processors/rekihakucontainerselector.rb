module UMPTG::Fulcrum::Metadata::Processors

  # Class selects references to resources found within
  # an EPUB produced by vendor Rekihaku.
  class RekihakuContainerSelector < UMPTG::Fragment::Selector
    def select_element(name, attrs = [])
      # Select img or a <div class="fig">.
      case name
      when "div"
        attrs_map = attrs.to_h
        if attrs_map.key?("class")
          attrs_map["class"].strip.split(' ').each do |attrval|
            return true if attrval == "fig"
          end
        end
      when "img"
        return true
      end
      return false
    end
  end
end
