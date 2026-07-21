module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessModeSufficientFilter < AccessFilter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and @property='schema:accessModeSufficient'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_accessmode_sufficient,
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

      AccessFilter.mode_report(
            issues,
            options: options,
            logger: (logger || @logger),
          )
    end

    def self.review_issues(issues, options: {})
      entry = options[:entry]
      media_list = entry.document.xpath(AccessFilter.MEDIA_XPATH)

      metadata_node = entry.document.xpath("//*[local-name()='metadata']").first

      acs_textual_issues = issues.select {|i|
              i.name == :epub_oebps_accessmode_sufficient and i.content.content.strip.downcase == 'textual'
            }
      acs_textual_visual_issues = issues.select {|i|
              i.name == :epub_oebps_accessmode_sufficient and (
                    i.content.content.strip.gsub(/[ ]+/, '').downcase == 'textual,visual' \
                    or i.content.content.strip.gsub(/[ ]+/, '').downcase == 'visual,textual'
                  )
            }

      if acs_textual_issues.count == 0 or acs_textual_visual_issues.count == 0
        issue = UMPTG::Issue.new(
                  name: :epub_oebps_accessmode_sufficient,
                  content: metadata_node
                )
        issues << issue

        if acs_textual_visual_issues.count == 0
          if media_list.count > 0
            markup = "<meta property=\"schema:accessModeSufficient\">textual,visual</>"
            issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                      issue,
                      options: {
                            action: :add_child,
                            markup: markup,
                            warning_msg: "#{issue.name} missing meta/@property=\"accessModeSufficient\"=\"textual,visual\""
                          }
                    )
          end
        end
        if acs_textual_issues.count == 0
          markup = "<meta property=\"schema:accessModeSufficient\">textual</>"
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    issue,
                    options: {
                          action: :add_child,
                          markup: markup,
                          warning_msg: "#{issue.name} missing meta/@property=\"accessModeSufficient\"=\"textual\""
                        }
                  )
        end
      end
    end
  end
end
