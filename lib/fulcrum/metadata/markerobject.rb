module UMPTG::Fulcrum::Metadata

  # Class represents additional resources (Marker)
  # found when processing an EPUB. The super contains
  # the Marker fragment while this class extends
  # the base to include the resource name.
  class MarkerObject < UMPTG::Fragment::Object
    attr_accessor :resource_name

    # Arguments:
    #   :node           XML fragment node
    #   :name           Fragment identifier, e.g. EPUB entry name.
    #   :resource_name  Resource name associated with fragment.
    def initialize(args = {})
      super(args)
      @resource_name = @properties[:resource_name]
    end

    def map
      row = super()
      row['resource_name'] = @resource_name
      return row
    end
  end
end
