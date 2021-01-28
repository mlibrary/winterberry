module UMPTG::FMetadata

  # Class is base object representing figures/images
  # found when processing an EPUB. The super contains
  # the figure/image fragment while this class extends
  # the base to include the figure caption.
  class FigureObject < UMPTG::Fragment::Object
    attr_accessor :caption

    def initialize(args = {})
      super(args)
      @resource_name = @node['src']
      @caption = args[:caption]
    end

    def map
      row = super()
      row['resource_name'] = @resource_name
      row['caption'] = @caption
      return row
    end
  end
end
