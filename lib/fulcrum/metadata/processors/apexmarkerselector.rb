module UMPTG::Fulcrum::Metadata::Processors

  # Class selects references to additional resources (Markers)
  # found within an EPUB produced by vendor Apex.
  class ApexMarkerSelector < UMPTG::Fragment::Selector
    def select_element(name, attrs = [])
      return name == 'p'
    end
  end
end
