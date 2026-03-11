module UMPTG::XHTML::Pipeline::Actions

  class NormalizeFigureContainerAction < UMPTG::XML::Pipeline::Actions::NormalizeAction

    def resolve(args = {})
      super(args)

      node_name = @action_node.name

      @action_node.name = "figure"
      add_info_msg("image: \"#{@resource_path}\" converted figure container from #{node_name} to #{@action_node.name}.")

      @status = NormalizeAction.NORMALIZED
    end
  end
end
