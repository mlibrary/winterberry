module UMPTG::EPUB::OEBPS::Pipeline

  class Processor < UMPTG::XML::Pipeline::Processor

    def review(issues, options: {})
      super(issues, options: options)

      if issues.count > 0
        UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessFeatureFilter.review(issues, options: options)
        UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessModeFilter.review(issues, options: options)
      end
    end
  end
end
