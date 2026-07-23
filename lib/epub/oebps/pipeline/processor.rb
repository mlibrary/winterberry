module UMPTG::EPUB::OEBPS::Pipeline
  class Processor < UMPTG::XML::Pipeline::Processor
=begin
    def review(issues, options: {})
      super(
              issues,
              options: options
            )
      entry = options[:entry]

      metadata_node = entry.document.xpath("//*[local-name()='metadata']").first
      raise "unable to locate OEBPS metadata node" if metadata_node.nil?

      Filter::AccessModeFilter.review_issues(issues, options: options)
      Filter::AccessModeSufficientFilter.review_issues(issues, options: options)
      Filter::AccessHazardFilter.review_issues(issues, options: options)
      Filter::AccessFeatureFilter.review_issues(issues, options: options)
    end
=end
  end
end
