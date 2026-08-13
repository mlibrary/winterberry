module UMPTG::XML::Pipeline::Actions

  class RemoveElementAction < UMPTG::Pipeline::NormalizeAction
    def resolve(options: {})
      super(options: options)

      reference_node = issue.content

      action_node_markup = issue.content.to_s
      issue.content.remove()
      add_info_msg("removed element #{action_node_markup}")

      @status = UMPTG::Action.COMPLETED
    end
  end
end

