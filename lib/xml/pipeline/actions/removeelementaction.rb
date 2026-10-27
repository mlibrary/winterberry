module UMPTG::XML::Pipeline::Actions

  class RemoveElementAction < UMPTG::Pipeline::NormalizeAction
    def resolve(options: {})
      super(options: options)

      reference_node = @properties[:reference_node] || issue.content

      action_node_markup = reference_node.to_s
      reference_node.remove()
      add_info_msg("removed element #{action_node_markup}")

      @status = UMPTG::Action.COMPLETED
    end
  end
end

