module UMPTG::Fulcrum::Resources::Filter

  class OPFFilter < UMPTG::XML::Pipeline::Filter
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
      a[:name] = :opf
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
  end
end
