module UMPTG::XML::Pipeline::Actions

  class RemoveElementAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      action_node = @properties[:action_node]

      action_node_markup = action_node.to_s
      action_node.remove()
      add_info_msg("removed element #{action_node_markup}")

      @status = UMPTG::Action.COMPLETED
    end
  end
end

