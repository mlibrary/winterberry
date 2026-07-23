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

    def self.report(issues, features, options: {}, logger: nil)
      unless issues.empty?
        property = issues.first.content['property']

        actions = []
        issues.each {|i| actions += i.actions }

        actions.each do |a|
          next unless a.class.name == "UMPTG::XML::Pipeline::Action"

          content = (a.issue.content.text || "").strip
          features[content] = true if features.key?(content)
        end

        features.each do |k,v|
          logger.info("#{issues.first.name}, <meta property=\"#{property}\">#{k}</meta> found") \
                if v
          #logger.warn("#{issues.first.name}, <meta property=\"#{property}\">#{k}</meta> not found") \
          #      unless v
        end
      end
    end

    def self.mode_report(issues, options: {}, logger: nil)
      features = {
          "auditory" => false,
          "tactile" => false,
          "textual" => false,
          "visual" => false,
        }
      self.report(
          issues,
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
