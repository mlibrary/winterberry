module UMPTG::Accessibility::Filter

  class OPFFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name() = 'metadata'
    ]
    PCKXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :opf
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      reference_node = args[:reference_node]

      raise "Unexpected element #{reference_node.name}" unless reference_node.name == "metadata"

      actions = []

      node = reference_node.xpath("./*[local-name()='meta' and @property='schema:accessModeSufficient' and string()='textual']").last
      if node.nil?
        node = reference_node.xpath("./*[local-name()='meta' and @property='schema:accessModeSufficient']").last
        node = reference_node.xpath("./*[local-name()='meta' and @property='schema:accessMode']").last \
              if node.nil?
        node = reference_node.xpath("./*[local-name()='meta' and @property]").last if node.nil?

        raise "No meta/@property element found" if node.nil?

        markup = '<meta property="schema:accessModeSufficient">textual</meta>'
        actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  name: name,
                  reference_node: node,
                  action: :add_next,
                  markup: markup,
                  warning_message: "#{name}, markup #{markup} not found."
                )
      else
        actions << UMPTG::XML::Pipeline::Action.new(
                        name: name,
                        reference_node: reference_node,
                        info_message: "#{name}, found #{node.name}/#{node['property']}/#{node.text}. No action needed."
                    )
      end

      return actions
    end
  end
end
