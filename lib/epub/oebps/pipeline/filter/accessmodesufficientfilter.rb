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
            name,
            "schema:accessModeSufficient",
            options: options,
            logger: (logger || @logger),
          )
    end

    def self.review_issues(entry_actions, access_mode_info, options: {})
      metadata_node = access_mode_info.oebps_entry_action.entry.document.xpath("//*[local-name()='metadata']").first
      raise "unable to locate OEBPS metadata node" if metadata_node.nil?

      issues = access_mode_info.oebps_entry_action.issues

      acs_textual_issues = issues.select {|i|
              i.name == :epub_oebps_accessmode_sufficient and i.content.content.strip.downcase == 'textual'
            }
      acs_textual_visual_issues = issues.select {|i|
              i.name == :epub_oebps_accessmode_sufficient and (
                    i.content.content.strip.gsub(/[ ]+/, '').downcase == 'textual,visual' \
                    or i.content.content.strip.gsub(/[ ]+/, '').downcase == 'visual,textual'
                  )
            }

      issue = nil
      condition = (access_mode_info.imgalt_total.count > 0 \
                                    and access_mode_info.imgalt_warnings.count == 0 \
                                    and !access_mode_info.imgalt_cover)
      case
      when (acs_textual_visual_issues.count == 0 and condition)
        # Add feature if it doesn't exist and the condition is true.
        issue = UMPTG::Issue.new(
                  name: :epub_oebps_accessmode_sufficient,
                  content: metadata_node
                )
        issues << issue

        markup = "<meta property=\"schema:accessModeSufficient\">textual,visual</>"
        issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  issue,
                  options: {
                        action: :add_child,
                        markup: markup,
                        warning_message: "#{issue.name} missing meta/@property=\"accessModeSufficient\"=\"textual,visual\""
                      }
                )
      when (acs_textual_visual_issues.count == 0 and !condition)
        # Skip add if feature is missing and condition is false.
      when (acs_textual_visual_issues.count > 0 and condition)
        # Skip add if feature exists and condition is true.
      else
        # Feature exists, but condition is false, report error
        issue = acs_textual_visual_issues.first
        act = UMPTG::Pipeline::Action.new(
              issue,
              options: options
            )
        act.add_error_msg("#{issue.name}, found meta/@property=\"accessModeSufficient\"=\"textual,visual\", but invalid alt text reported")
        issue.actions << act
      end

      if acs_textual_issues.count == 0
        if issue.nil?
          issue = UMPTG::Issue.new(
                    name: :epub_oebps_accessmode_sufficient,
                    content: metadata_node
                  ) if issue.nil?
          issues << issue
        end

        markup = "<meta property=\"schema:accessModeSufficient\">textual</>"
        issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  issue,
                  options: {
                        action: :add_child,
                        markup: markup,
                        warning_message: "#{issue.name} missing meta/@property=\"accessModeSufficient\"=\"textual\""
                      }
                )
      end
    end
  end
end
