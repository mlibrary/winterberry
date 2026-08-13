module UMPTG::XML::Pipeline::Actions

  class RenameElementAction < UMPTG::Pipeline::NormalizeAction
    def resolve(options: {})
      super(options: options)

      reference_node = issue.content
      new_element_name = @properties[:new_element_name]

      current_element_name = reference_node.name
      clss = reference_node["class"]
      reference_node.name = new_element_name
      add_info_msg("#{issue.name}: renamed element #{current_element_name} to #{reference_node.name}")

      @status = UMPTG::Action.COMPLETED
    end
  end
end

