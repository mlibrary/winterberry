module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessFeatureFilter < AccessFilter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and @property='schema:accessibilityFeature'
    ]
    SXPATH

    FEATURES = [
          "alternativeText",
          "displayTransformability",
          "pageBreakMarkers",
          "pageNavigation",
          "printPageNumbers",
          "readingOrder",
          "structuralNavigation",
          "tableOfContents"
        ]

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

      features_found = {}
      FEATURES.each {|f| features_found[f] = false }
      AccessFilter.report(
            issues,
            name,
            "schema:accessibilityFeature",
            features_found,
            options: options,
            logger: (logger || @logger),
          )
    end

    def self.review_issues(entry_actions, access_mode_info, options: options)
      issues = access_mode_info.oebps_entry_action.issues

      metadata_node = access_mode_info.oebps_entry_action.entry.document.xpath("//*[local-name()='metadata']").first

      features_found = {}
      FEATURES.each {|f| features_found[f] = nil }
      issues.each do |issue|
        feature = issue.content.content.strip
        features_found[feature] = issue unless feature.empty?
      end

      features_found.each do |feature,issue|
        condition = false
        msg = ""
        case feature
        when "alternativeText"
          # True if there are no reported img alt text issues.
          condition = (access_mode_info.imgalt_total.count > 0 \
                  and access_mode_info.imgalt_warnings.count == 0 \
                  and !access_mode_info.imgalt_cover)
          errmsg = "but invalid alt text reported"
        when "pageBreakMarkers"
          # True if pagebreaks do exist.
          condition = access_mode_info.pagebreak.count > 0
          errmsg = "but no pagebreaks found"
        when "pageNavigation"
          # True if a page list exists.
          toc_doc = access_mode_info.oebps_entry_action.entry.files.epub.rendition.navigation.entry.document
          pagelist_node = toc_doc.xpath("//*[local-name()='nav' and (@epub:type='page-list' or @role='doc-pagelist')]").first
          condition = !pagelist_node.nil?
          errmsg = "but no pagelist found"
        when "tableOfContents"
          # True if a TOC exists.
          condition = !access_mode_info.oebps_entry_action.entry.files.epub.rendition.navigation.nil?
          errmsg = "but no TOC found"
        else
          next
        end

        case
        when (issue.nil? and condition)
          # Add feature if it doesn't exist and the condition is true.
        when (issue.nil? and !condition)
          # Skip add if feature is missing and condition is false.
          next
        when (!issue.nil? and condition)
          # Skip add if feature exists and condition is true.
          next
        else
          # Feature exists, but condition is false, report error
          act = UMPTG::Pipeline::Action.new(
                issue,
                options: options
              )
          act.add_error_msg("#{issue.name}, found feature=\"#{feature}\" #{errmsg}.")
          issue.actions << act
          next
        end

        issue = UMPTG::Issue.new(
                  name: :epub_oebps_accessfeature,
                  content: metadata_node
                )
        issues << issue

        markup = "<meta property=\"schema:accessibilityFeature\">#{feature}</>"
        issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  issue,
                  options: {
                        action: :add_child,
                        markup: markup,
                        warning_message: "#{issue.name} missing meta/@property=\"accessibilityFeature\"=\"#{feature}\""
                      }
                )
      end

    end
  end
end
