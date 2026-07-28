module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessFeatureFilter < AccessFilter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and @property='schema:accessibilityFeature'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_accessfeature,
              XPATH,
              options: options
            )
    end

    def report(issues, options: {}, logger: nil)
      super(issues, options: options, logger: logger)

      features = {
            "alternativeText" => false,
            "printPageNumbers" => false,
            "structuralNavigation" => false,
            "displayTransformability" => false,
            "readingOrder" => false
          }
      AccessFilter.report(
            issues,
            name,
            "schema:accessibilityFeature",
            features,
            options: options,
            logger: (logger || @logger),
          )
    end

    def self.review_issues(entry_actions, access_mode_info, options: options)
      issues = access_mode_info.oebps_entry_action.issues

      metadata_node = access_mode_info.oebps_entry_action.entry.document.xpath("//*[local-name()='metadata']").first

      acf_issues = issues.select {|i| i.name == :epub_oebps_accessfeature }

      if acf_issues.count == 0
        issue = UMPTG::Issue.new(
                  name: :epub_oebps_accessfeature,
                  content: metadata_node
                )
        issues << issue

        features = ["displayTransformability", "readingOrder"]

        acf_alttext_issues = access_mode_info.imgalt_total.select do |i|
          #next unless i.name == :xhtml_img_alttext
          next if (i.content['role'] || "").strip.downcase == "presentation"
          next unless (i.content['alt'] || "").strip.empty?
          i
        end
        features << "alternativeText" if acf_alttext_issues.count == 0
        features << "pageBreakMarkers" unless access_mode_info.pagebreak.count == 0
        features << "tableOfContents" \
              unless access_mode_info.oebps_entry_action.entry.files.epub.rendition.navigation.nil?

        features.each do |f|
          markup = "<meta property=\"schema:accessibilityFeature\">#{f}</>"
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    issue,
                    options: {
                          action: :add_child,
                          markup: markup,
                          warning_msg: "#{issue.name} missing meta/@property=\"accessibilityFeature\"=\"#{f}\""
                        }
                  )
        end

        ac_summary_issues = issues.select {|i| i.name == :epub_oebps_access_summary }
        if ac_summary_issues.count == 0
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    issue,
                    options: {
                          action: :add_child,
                          markup: AccessFilter.ACCESSIBILITY_SUMMARY,
                          warning_msg: "#{issue.name} missing meta/@property=\"accessibilitySummary\""
                        }
                  )
        end
      end
    end
  end
end
