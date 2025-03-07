module UMPTG::EPUB::ECheck::Filter

  class XHTMLFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name()='hgroup'
    ]|
    //*[
    @role
    ]
    PCKXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      reference_node = args[:reference_node]

      actions = []

      if reference_node.name == "hgroup"
        actions += process_hgroup(reference_node, args)
      end
      if reference_node.key?('role')
        actions += process_role(reference_node, args)
      end

      if actions.empty?
        actions << UMPTG::XML::Pipeline::Action.new(
                        name: name,
                        reference_node: reference_node,
                        info_message: "#{name}, #{reference_node.name}"
                    )
      end
      return actions
    end

    private

    def process_hgroup(reference_node, args)
      actions = []

      # Confirm that the first child is either h1 or h2 element
      children = reference_node.element_children
      unless ["h1", "h2", "h3", "h4", "h5", "h6"].include?(children[0].name)
        actions << UMPTG::XML::Pipeline::Actions::RenameElementAction.new(
                  name: name,
                  reference_node: reference_node,
                  action_node: children[0],
                  new_element_name: "h1",
                  warning_message: "#{name}, found #{reference_node.name}/#{children[0].name}"
                )
      end

      # If any of the other children are h1 or h2, convert to a p.
      children[1..-1].each do |child|
        if ["h1", "h2", "h3", "h4", "h5", "h6"].include?(child.name)
          actions << UMPTG::XML::Pipeline::Actions::RenameElementAction.new(
                    name: name,
                    reference_node: reference_node,
                    action_node: child,
                    new_element_name: "p",
                    warning_message: "#{name}, found #{reference_node.name}/#{child.name}"
                  )
        end
      end

      return actions
    end

    def process_role(reference_node, args)
      role = reference_node['role']

      actions = []

      case
      when (["meta"].include?(reference_node.name) \
            or ["doc-biblioentry", "doc-cover", "doc-endnote", "doc-endnotes", "doc-footnote"].include?(role))
        actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: "role",
                  warning_message: "#{name}, found #{reference_node.name}/@role=\"#{role}\"."
                )
      when ["noteref"].include?(role)
        actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: "role",
                  attribute_value: "doc-" + role,
                  warning_message: "#{name}, found #{reference_node.name}/@role=\"#{role}\"."
                )
      end

      return actions
    end
  end
end
