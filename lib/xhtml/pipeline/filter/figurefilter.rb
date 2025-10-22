module UMPTG::XHTML::Pipeline::Filter

  class FigureFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml_figure
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <figure> element

      action_list = []

      if reference_node.name == 'figure'
        id = reference_node['id'] || ""
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 info_message: \
                   "#{name}, #{reference_node.name} found @id=\"#{id}\""
             )
      end
      return action_list
    end
  end
end
