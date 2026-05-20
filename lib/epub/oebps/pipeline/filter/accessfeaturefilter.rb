module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessFeatureFilter < UMPTG::XML::Pipeline::Filter
  # <meta property="schema:accessibilityFeature">alternativeText</meta>
  # <meta property="schema:accessibilityFeature">printPageNumbers</meta>

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

    def review(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      if issue.content['property'] == 'schema:accessibilityFeature'
        issue.actions << UMPTG::XML::Pipeline::Action.new(
               issue,
               options: {
                   info_message: "#{name}, found #{issue.content}"
                 }
           )
      end
    end

    def report(issues, options: {}, logger: nil)
      super(issues, options: options, logger: logger)

      llogger = logger || @logger

      actions = []
      issues.each {|i| actions += i.actions }

      # <meta property="schema:accessibilityFeature">alternativeText</meta>
      # <meta property="schema:accessibilityFeature">printPageNumbers</meta>
      features = {
            "alternativeText" => false,
            "printPageNumbers" => false,
            "structuralNavigation" => false,
            "displayTransformability" => false,
            "readingOrder" => false
          }
      actions.each do |a|
        next unless a.class.name == "UMPTG::XML::Pipeline::Action"

        content = (a.issue.content.text || "").strip
        features[content] = true if features.key?(content)
      end

      features.each do |k,v|
        llogger.info("#{name}, <meta property=\"schema:accessibilityFeature\">#{k}</meta> found") \
              if v
        llogger.warn("#{name}, <meta property=\"schema:accessibilityFeature\">#{k}</meta> not found") \
              unless v
      end
    end
  end
end
