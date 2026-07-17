module UMPTG::EPUB::OEBPS::Pipeline
  class Processor < UMPTG::XML::Pipeline::Processor

    MEDIA_XPATH = <<-SXPATH
    //*[
    local-name()='manifest'
    ]/*[
    local-name()='item' and (
    starts-with(@media-type,'image/')
    or starts-with(@media-type, 'video/')
    )
    ]
    SXPATH

    ACCESSIBILITY_SUMMARY = "<meta property=\"schema:accessibilitySummary\">This publication meets the EPUB Accessibility requirements and it also meets the Web Content Accessibility Guidelines (WCAG-AA). It is screen-reader friendly and is accessible to persons with disabilities. A book with images which are defined with accessible structural markup. This book contains various accessibility features such as alternative text and long descriptions for images, tables, table of content, page-list, landmark, reading order, structural navigation, index and semantic structure.</meta>"

    def review(issues, options: {})
      super(
              issues,
              options: options
            )

      entry = options[:entry]
      media_list = entry.document.xpath(MEDIA_XPATH)

      metadata_node = entry.document.xpath("//*[local-name()='metadata']").first
      raise "unable to locate OEBPS metadata node" if metadata_node.nil?

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

      ach_issues = issues.select {|i| i.name == :epub_oebps_access_hazard }
      if ach_issues.count == 0
        issue = UMPTG::Issue.new(
                  name: :epub_oebps_access_hazard,
                  content: metadata_node
                )
        issues << issue

        #["noFlashingHazard", "noSoundHazard", "noMotionSimulationHazard"].each do |hazard|
        ["unknown"].each do |hazard|
          markup = "<meta property=\"schema:accessibilityHazard\">#{hazard}</>"
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    issue,
                    options: {
                          action: :add_child,
                          markup: markup,
                          warning_msg: "#{issue.name} missing meta/@property=\"accessibilityHazard\"=\"#{hazard}\""
                        }
                  )
        end
      end

      acf_issues = issues.select {|i| i.name == :epub_oebps_accessfeature }
      if acf_issues.count == 0
        issue = UMPTG::Issue.new(
                  name: :epub_oebps_accessfeature,
                  content: metadata_node
                )
        issues << issue

        features = ["displayTransformability", "readingOrder"]

        acf_alttext_issues = issues.select do |i|
          next unless i.name == :xhtml_img_alttext
          next if (i.content['role'] || "").strip.downcase == "presentation"
          next unless (i.content['alt'] || "").strip.empty?
          i
        end
        features << "alternativeText" if acf_alttext_issues.count == 0

        acf_pagebreak_issues = issues.select {|i| i.name == :xhtml_pagebreak }
        features << "pageBreakMarkers" unless acf_pagebreak_issues.count == 0

        features << "tableOfContents" unless entry.files.epub.rendition.navigation.nil?

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
                          markup: ACCESSIBILITY_SUMMARY,
                          warning_msg: "#{issue.name} missing meta/@property=\"accessibilitySummary\""
                        }
                  )
        end
      end
    end
  end
end
