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

      #logger.info("epub_oebps_access_summary, <meta property=\"schema:accessibilitySummary\">...</meta> found") \
      #      if v
      logger.warn("epub_oebps_access_summary, <meta property=\"schema:accessibilitySummary\">...</meta> not found")
    end

    def self.review_issues(entry_actions, access_mode_info, options: {})
      metadata_node = access_mode_info.oebps_entry_action.entry.document.xpath("//*[local-name()='metadata']").first
      raise "unable to locate OEBPS metadata node" if metadata_node.nil?

      issues = access_mode_info.oebps_entry_action.issues
      ac_summary_issues = issues.select {|i| i.name == :epub_oebps_access_summary }

      if ac_summary_issues.count == 0
        issue = UMPTG::Issue.new(
                  name: :epub_oebps_access_summary,
                  content: metadata_node
                )
        issues << issue

        con = "This Publication meets the requirements of the EPUB Accessibility specification with conformance to WCAG 2.0 Level AA. This book contains various accessibility features such as alternative text for images, table of content, page-list, landmark, reading order and structural navigation."
        markup = "<meta property=\"schema:accessibilitySummary\">#{con}</>"
        issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  issue,
                  options: {
                        action: :add_child,
                        markup: markup,
                        warning_message: "#{issue.name} missing meta/@property=\"accessibilitySummary\""
                      }
                )
      end
    end
  end
end
