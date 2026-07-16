module UMPTG::EPUB::OEBPS::Pipeline
  class Processor < UMPTG::XML::Pipeline::Processor

    def review(issues, options: {})
      super(
              issues,
              options: options
            )

      entry = options[:entry]
      image_list = entry.document.xpath("//*[local-name()='manifest']/*[local-name()='item' and starts-with(@media-type,'image/')]")

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
          if image_list.count > 0
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
          if image_list.count > 0
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

        ["noFlashingHazard", "noSoundHazard", "noMotionSimulationHazard"].each do |hazard|
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
    end
  end
end
