module UMPTG::Review

  class RenameElementAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      action_node = @properties[:action_node]

      action_node_name = action_node.name
      action_node.name = "p"
      add_info_msg("rename element #{action_node_name} to #{action_node.name}")

      @status = NormalizeAction.NORMALIZED
    end
  end
end

