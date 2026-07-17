module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessFeatureFilter < AccessFilter
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
            features,
            options: options,
            logger: (logger || @logger),
          )
    end
  end
end
