module UMPTG::Review

  class NormalizeImageContainerAction < Action

    def process(args = {})
      super(args)

      node_name = @action_node.name

      @action_node.name = "div"
      add_info_msg("Image:  #{@reference_node['src']} converted image container from #{node_name} to #{@action_node.name}.")

      @status = Action.COMPLETED
    end
  end
end
