module UMPTG::EPUB::Processors
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
