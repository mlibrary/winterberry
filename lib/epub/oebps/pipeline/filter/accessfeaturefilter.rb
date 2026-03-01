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

    def initialize(options: nil)
      super(
              name: :epub_oebps_accessfeature,
              xpath: XPATH,
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
               name: issue.name,
               reference_node: issue.content,
               info_message: "#{name}, found #{issue.content}"
           )
      end
    end

    def self.review(issues, options: {})
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

        content = (a.reference_node.content || "").strip
        features[content] = true if features.key?(content)
      end

      features.each do |k,v|
        unless v
          issue = UMPTG::Issue.new(name: :epub_oebps_accessfeature, content: issues.first.content.parent)
          issues << issue

          act = UMPTG::Pipeline::Action.new(
                  issue,
                  options: options
                  )
          act.add_warning_msg("#{issue.name}, <meta property=\"schema:accessibilityFeature\">#{k}</meta> not found")
          issue.actions << act
        end
      end
    end
  end
end
