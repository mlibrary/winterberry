module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessHazardFilter < AccessFilter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and @property='schema:accessibilityHazard'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_access_hazard,
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

      features = {
            "flashing" => false,
            "motionSimulation" => false,
            "sound" => false,
            "none" => false,
            "noFlashingHazard" => false,
            "noMotionSimulationHazard" => false,
            "noSoundHazard" => false,
            "unknown" => false,
            "unknownFlashingHazard" => false,
            "unknownMotionSimulationHazard" => false,
            "unknownSoundHazard" => false,
         }
      AccessFilter.report(
            issues,
            name,
            "schema:accessibilityHazard",
            features,
            options: options,
            logger: (logger || @logger),
          )
    end

    def self.review_issues(entry_actions, access_mode_info, options: {})
      issues = access_mode_info.oebps_entry_action.issues

      metadata_node = access_mode_info.oebps_entry_action.entry.document.xpath("//*[local-name()='metadata']").first

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
    end
  end
end
