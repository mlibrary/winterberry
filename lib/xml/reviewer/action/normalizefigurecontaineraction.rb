module UMPTG::XML::Reviewer::Action

  require_relative("normalizefigureaction")

  class NormalizeFigureContainerAction < NormalizeFigureAction

    def process(args = {})
      super(args)

      node_name = @action_node.name

      @action_node.name = "figure"
      add_info_msg("image: \"#{@resource_path}\" converted figure container from #{node_name} to #{@action_node.name}.")

      @status = UMPTG::Action.COMPLETED
    end
  end
end
