module UMPTG::EPUB::Processors

  # Class is base object representing figures/images
  # found when processing an EPUB. The super contains
  # the figure/image fragment while this class extends
  # the base to include the figure caption.
  class Object < UMPTG::Fragment::Object
    attr_accessor :caption

    def initialize(args = {})
      super(args)
      @caption = args[:caption]
    end

    def map
      row = super()
      row['caption'] = @caption
      return row
    end
  end
end
