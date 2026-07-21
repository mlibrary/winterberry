module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessModeFilter < AccessFilter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and @property='schema:accessMode'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_accessmode,
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

      ac_textual_issues = issues.select {|i|
              i.name == :epub_oebps_accessmode and i.content.content.strip.downcase == 'textual'
            }
      ac_visual_issues = issues.select {|i|
              i.name == :epub_oebps_accessmode and i.content.content.strip.downcase == 'visual'
            }

      if ac_textual_issues.count == 0 or ac_visual_issues.count == 0
        issue = UMPTG::Issue.new(
                  name: :epub_oebps_accessmode,
                  content: metadata_node
                )
        issues << issue

        if ac_textual_issues.count == 0
          markup = "<meta property=\"schema:accessMode\">textual</>"
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    issue,
                    options: {
                          action: :add_child,
                          markup: markup,
                          warning_msg: "#{issue.name} missing meta/@property=\"accessMode\"=\"textual\""
                        }
                  )
        end
        if ac_visual_issues.count == 0
          if media_list.count > 0
            markup = "<meta property=\"schema:accessMode\">visual</>"
            issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                      issue,
                      options: {
                            action: :add_child,
                            markup: markup,
                            warning_msg: "#{issue.name} missing meta/@property=\"accessMode\"=\"visual\""
                          }
                    )
          end
        end
      end
    end
  end
end
