module UMPTG::Review

  class RemoveElementMediaAction < Action
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      action_node = @properties[:action_node]
      action_node_str = action_node.to_s

      action_node.replace(action_node.children)
      add_info_msg("removed #{action_node_str}")

      @status = Action.COMPLETED
    end
  end
end

