module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessibleFilter < UMPTG::XML::Pipeline::Filter
  # <meta property="schema:accessModeSufficient">textual</meta>
  # <meta property="schema:accessibilityFeature">alternativeText</meta>
  # <meta property="schema:accessibilityFeature">printPageNumbers</meta>
  # <meta property="pageBreakSource">...</meta>

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta'
    and (
    (@property='schema:accessModeSufficient' and text()='textual')
    or (@property='schema:accessibilityFeature' and (text()='alternativeText' or text()='printPageNumbers'))
    or @property='pageBreakSource'
    )
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_accessible,
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

      action_list = []

      if issue.content.name == 'meta'
        action_list << UMPTG::XML::Pipeline::Action.new(
               name: issue.name,
               reference_node: issue.content,
               info_message: "#{issue.name}, found #{issue.content}"
           )
      end
      return action_list
    end

    def report(issue, options: {}, logger: nil)
      logger.info("metadata issues:#{issue.actions.count}")

      # <meta property="schema:accessModeSufficient">textual</meta>
      act = issue.actions.select {|a|
          a.reference_node['property'] == 'schema:accessModeSufficient' and a.reference_node.content == "textual"
        }
      if act.empty?
        logger.warn("accessModeSufficient=textual not found")
      else
        logger.info("accessModeSufficient=textual found")
      end

      # <meta property="schema:accessibilityFeature">alternativeText</meta>
      act = issue.actions.select {|a|
          a.reference_node['property'] == 'schema:accessibilityFeature' and a.reference_node.content == "alternativeText"
        }
      if act.empty?
        logger.warn("accessibilityFeature=alternativeText not found")
      else
        logger.info("accessibilityFeature=alternativeText found")
      end

      # <meta property="schema:accessibilityFeature">printPageNumbers</meta>
      act = issue.actions.select {|a|
          a.reference_node['property'] == 'schema:accessibilityFeature' and a.reference_node.content == "printPageNumbers"
        }
      if act.empty?
        logger.warn("accessibilityFeature=printPageNumbers not found")
      else
        logger.info("accessibilityFeature=printPageNumbers found")
      end

      # <meta property="pageBreakSource">...</meta>
      act = issue.actions.select {|a| a.reference_node['property'] == 'pageBreakSource' }
      if act.empty?
        logger.warn("pageBreakSource not found")
      else
        logger.info("pageBreakSource found")
      end
    end
  end
end
