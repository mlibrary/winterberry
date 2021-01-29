module UMPTG::FMetadata

  # Class represents resources references figures/images
  # found when processing an EPUB. The super contains
  # the figure/image fragment while this class extends
  # the base to include the figure caption and associated
  # resource name.
  class FigureObject < UMPTG::Fragment::Object
    attr_accessor :caption

    # Arguments:
    #   :node         XML fragment node, @src contains resource name.
    #   :name         Fragment identifier, e.g. EPUB entry name.
    #   :caption      Resource caption
    def initialize(args = {})
      super(args)

      @resource_name = @node['src']
      @caption = @properties[:caption]
    end

    def map
      row = super()
      row['resource_name'] = @resource_name
      row['caption'] = @caption
      return row
    end
  end
end
