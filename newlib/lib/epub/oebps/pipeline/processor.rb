module UMPTG::EPUB::OEBPS::Pipeline

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      a = args.clone

      if a[:filters].nil?
        a[:filters] = FILTERS
      else
        a[:filters] = a[:filters].merge(FILTERS)
      end

      super(a)
    end
  end
end
