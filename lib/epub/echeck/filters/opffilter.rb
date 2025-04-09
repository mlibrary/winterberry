module UMPTG::EPUB::ECheck::Filter

  class OPFFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name()='metadata'
    ]/*[
    name()='dc:date' and starts-with(string(),'c')
    ]|//*[
    local-name()='itemref' and @linear='no'
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

      actions = []

      case
      when reference_node.name == 'dc:date'
        new_content = reference_node.content[1..-1]
        actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  name: name,
                  reference_node: reference_node,
                  action: :replace_content,
                  markup: new_content,
                  warning_message: "#{name}, invalid date #{reference_node.name}=#{reference_node.content}."
                )
      when reference_node.name == 'itemref'
        actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: "linear",
                  warning_message: "#{name}, found #{reference_node.name}/@linear=\"#{reference_node['linear']}\"."
                )
      end
      return actions
    end
  end
end
