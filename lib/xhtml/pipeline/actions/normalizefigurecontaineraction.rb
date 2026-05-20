module UMPTG::XHTML::Pipeline::Actions

  class NormalizeFigureContainerAction < UMPTG::XML::Pipeline::Actions::NormalizeAction

    def resolve(options: {})
      super(options: options)

      node_name = @action_node.name

      @action_node.name = "figure"
      add_info_msg("#{name}: \"#{@resource_path}\" converted figure container from #{node_name} to #{@action_node.name}.")

      @status = UMPTG::XML::Pipeline::Actions::NormalizeAction.COMPLETED
    end
  end
end
