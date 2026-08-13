module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessFilter < UMPTG::XML::Pipeline::Filter

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

    AUDIO_VIDEO_MEDIA_XPATH = <<-AXPATH
    //*[
    local-name()='manifest'
    ]/*[
    local-name()='item' and (
    starts-with(@media-type,'audio/')
    or starts-with(@media-type, 'video/')
    )
    ]
    AXPATH

    ACCESSIBILITY_SUMMARY = "<meta property=\"schema:accessibilitySummary\">This publication meets the EPUB Accessibility requirements and it also meets the Web Content Accessibility Guidelines (WCAG-AA). It is screen-reader friendly and is accessible to persons with disabilities. A book with images which are defined with accessible structural markup. This book contains various accessibility features such as alternative text and long descriptions for images, tables, table of content, page-list, landmark, reading order, structural navigation, index and semantic structure.</meta>"

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      issue.actions << UMPTG::XML::Pipeline::Action.new(
             issue,
             options: {
                 info_message: "#{name}, found #{issue.content['property']}=\"#{issue.content.content}\""
               }
         )
    end

    def self.report(issues, issue_name, property, features, options: {}, logger: nil)
      unless issues.empty?
        actions = []
        issues.each {|i| actions += i.actions }

        actions.each do |a|
          #next unless a.class.name == "UMPTG::XML::Pipeline::Action"
          content = (a.resolved_content.text || "").strip if a.is_a?(UMPTG::Pipeline::NormalizeAction) and !a.resolved_content.nil?
          content = (a.issue.content.text || "").strip unless a.is_a?(UMPTG::Pipeline::NormalizeAction)
          features[content] = true if features.key?(content)
        end
      end

      features.each do |k,v|
        #logger.info("#{issue_name}, <meta property=\"#{property}\">#{k}</meta> found") \
        #      if v
        logger.warn("#{issue_name}, <meta property=\"#{property}\">#{k}</meta> not found") \
              unless v
      end
    end

    def self.mode_report(issues, issue_name, property, options: {}, logger: nil)
      features = {
          "auditory" => false,
          "tactile" => false,
          "textual" => false,
          "visual" => false,
        }
      self.report(
          issues,
          issue_name,
          property,
          features,
          options: options,
          logger: logger
        )
    end

    def self.MEDIA_XPATH
      return MEDIA_XPATH
    end

    def self.ACCESSIBILITY_SUMMARY
      return ACCESSIBILITY_SUMMARY
    end
  end
end
