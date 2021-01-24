module UMPTG::FMetadata

  # Class is base object representing figures/images
  # found when processing an EPUB. The super contains
  # the figure/image fragment while this class extends
  # the base to include the figure caption.
  class MarkerObject < UMPTG::Fragment::Object
    attr_accessor :resource_name

    def initialize(args = {})
      super(args)
      @resource_name = args[:resource_name]
    end

    def map
      row = super()
      row['resource_name'] = @resource_name
      return row
    end
  end
end
