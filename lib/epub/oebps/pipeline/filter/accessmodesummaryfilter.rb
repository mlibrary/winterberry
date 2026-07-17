module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessSummaryFilter < AccessFilter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and @property='schema:accessibilitySummary'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_access_summary,
              XPATH,
              options: options
            )
    end

    def report(issues, options: {}, logger: nil)
      super(
            issues,
            options: options,
            logger: logger
          )

      features = {}
      issues.each {|i| features[i.content.content] = false }
      AccessFilter.report(
            issues,
            features,
            options: options,
            logger: (logger || @logger),
          )
    end
  end
end
