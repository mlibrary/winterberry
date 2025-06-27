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

    def initialize(args = {})
      a = args.clone
      a[:name] = :epub_oebps_accessible
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <meta> element

      action_list = []

      if reference_node.name == 'meta'
        action_list << UMPTG::XML::Pipeline::Action.new(
               name: name,
               reference_node: reference_node,
               info_message: "#{name}, found #{reference_node}"
           )
      end
      return action_list
    end

    def process_action_results(args = {})
      action_results = args[:action_results]
      actions = args[:actions]
      logger = args[:logger]

      logger.info("metadata issues:#{actions.count}")

      # <meta property="schema:accessModeSufficient">textual</meta>
      act = actions.select {|a|
          a.reference_node['property'] == 'schema:accessModeSufficient' and a.reference_node.content == "textual"
        }
      if act.empty?
        logger.warn("accessModeSufficient=textual not found")
      else
        logger.info("accessModeSufficient=textual found")
      end

      # <meta property="schema:accessibilityFeature">alternativeText</meta>
      act = actions.select {|a|
          a.reference_node['property'] == 'schema:accessibilityFeature' and a.reference_node.content == "alternativeText"
        }
      if act.empty?
        logger.warn("accessibilityFeature=alternativeText not found")
      else
        logger.info("accessibilityFeature=alternativeText found")
      end

      # <meta property="schema:accessibilityFeature">printPageNumbers</meta>
      act = actions.select {|a|
          a.reference_node['property'] == 'schema:accessibilityFeature' and a.reference_node.content == "printPageNumbers"
        }
      if act.empty?
        logger.warn("accessibilityFeature=printPageNumbers not found")
      else
        logger.info("accessibilityFeature=printPageNumbers found")
      end

      # <meta property="pageBreakSource">...</meta>
      act = actions.select {|a| a.reference_node['property'] == 'pageBreakSource' }
      if act.empty?
        logger.warn("pageBreakSource not found")
      else
        logger.info("pageBreakSource found")
      end
    end
  end
end
