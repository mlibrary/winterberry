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
      llogger = logger || @logger

      puts "issues=#{issues.count}"
      #logger.info("epub_oebps_access_summary, <meta property=\"schema:accessibilitySummary\">...</meta> found") \
      #      if v
      logger.warn("epub_oebps_access_summary, <meta property=\"schema:accessibilitySummary\">...</meta> not found")
    end
  end
end
