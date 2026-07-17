module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessFilter < UMPTG::XML::Pipeline::Filter
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
  end
end
