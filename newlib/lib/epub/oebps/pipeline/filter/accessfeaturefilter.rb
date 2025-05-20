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

    def initialize(args = {})
      a = args.clone
      a[:name] = :epub_oebps_accessfeature
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <meta> element

      action_list = []

      if reference_node['property'] == 'schema:accessibilityFeature'
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

      # <meta property="schema:accessibilityFeature">alternativeText</meta>
      # <meta property="schema:accessibilityFeature">printPageNumbers</meta>
      features = {
            "alternativeText" => false,
            "printPageNumbers" => false,
            "structuralNavigation" => false,
            "displayTransformability" => false,
            "readingOrder" => false
          }
      alt_text_found = print_page_numbers = false
      actions.each do |a|
        content = (a.reference_node.content || "").strip
        features[content] = true if features.key?(content)
      end

      features.each do |k,v|
        if v
          logger.info("<meta property=\"schema:accessibilityFeature\">#{k}</meta> found")
        else
          logger.warn("<meta property=\"schema:accessibilityFeature\">#{k}</meta> not found")
        end
      end
    end
  end
end
