module UMPTG::EPUB::ECheck::Filter

  class XHTMLFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name()='hgroup'
    ]//*[
    local-name()='h2'
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
      when "h2"
        actions += process_hgroup_h2(reference_node, args)
      else
        actions << UMPTG::XML::Pipeline::Action.new(
                        name: name,
                        reference_node: reference_node,
                        info_message: "#{name}, #{reference_node.name}"
                    )
      end
      return actions
    end

    private

    def process_hgroup_h2(reference_node, args)
      actions = []

      actions << UMPTG::XML::Pipeline::Actions::RenameElementAction.new(
                name: name,
                reference_node: reference_node,
                action_node: reference_node,
                new_element_name: "p",
                warning_message: "#{name}, found hgroup/h2"
              )

      return actions
    end
  end
end
