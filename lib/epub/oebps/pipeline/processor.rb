module UMPTG::EPUB::OEBPS::Pipeline

  class Processor < UMPTG::XML::Pipeline::Processor

    def resolve(issues, options: {})
      super(issues, options: options)

      if issues.count > 0
        UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessFeatureFilter.resolve(issues, options: options)
        UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessModeFilter.resolve(issues, options: options)
      end
    end
  end
end
