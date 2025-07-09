module UMPTG::EPUB::ECheck::Filter

  class XHTMLFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name()='hgroup'
    ]|
    //*[
    @role
    ]|
    //*[
    local-name()='head'
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

      case reference_node.name
      when "head"
        actions += process_head_element(reference_node, args)
      when "hgroup"
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

    def process_head_element(reference_node, args)
      actions = []
      xpath = "./*[local-name()='title']"
      title_node = reference_node.xpath(xpath).first
      if title_node.nil?
        actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  name: name,
                  reference_node: reference_node,
                  action: :add_child,
                  markup: "<title>#{name}</title>",
                  warning_message: "#{name}, missing #{reference_node.name}/title."
                )
      elsif title_node.content.strip.empty?
        actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  name: name,
                  reference_node: reference_node,
                  action: :replace_content,
                  markup: name,
                  warning_message: "#{name}, empty #{reference_node.name}/title."
                )
      end

      xpath = "./*[local-name()='meta' and @name='viewport' and @content='width=auto,height=auto']"
      viewport_node = reference_node.xpath(xpath).first
      unless viewport_node.nil?
        content = viewport_node['content']
        actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                  name: name,
                  reference_node: viewport_node,
                  attribute_name: "content",
                  attribute_value: "width=device-width,height=device-height",
                  warning_message: "#{name}, found #{viewport_node.name}/@content=\"#{content}\"."
                )
      end
      return actions
    end

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
            or ["doc-biblioentry", "doc-cover", "doc-endnote", "doc-endnotes", "doc-footnote", "doc-halftitle"].include?(role))
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
