module UMPTG::XML::Pipeline::Actions

  class RenameElementAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      action_node = @properties[:action_node]
      new_element_name = @properties[:new_element_name]

      current_element_name = action_node.name
      clss = action_node["class"]
      action_node.name = new_element_name
      add_info_msg("Renamed element #{current_element_name} to #{action_node.name}, class=#{clss}")

      @status = UMPTG::Action.COMPLETED
    end
  end
end

