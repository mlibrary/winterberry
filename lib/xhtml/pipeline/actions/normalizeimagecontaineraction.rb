module UMPTG::XHTML::Pipeline::Actions

  class NormalizeImageContainerAction < UMPTG::Pipeline::NormalizeAction

    def resolve(options: {})
      super(options: options)

=begin
      node_name = @action_node.name

      @action_node.name = "div"
      add_info_msg("image: \"#{@resource_path}\" converted image container from #{node_name} to #{@action_node.name}.")
      nested_node = @action_node.document.create_element("div")
      @action_node.add_previous_sibling(nested_node)
      nested_node.add_child(@action_node)
      add_info_msg("image: \"#{@resource_path}\" nested image container #{node_name} within #{nested_node.name}.")
=end

      #@status = NormalizeAction.NORMALIZED
      @status = Action.NO_ACTION
    end
  end
end
