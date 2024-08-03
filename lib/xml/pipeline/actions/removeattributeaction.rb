module UMPTG::XML::Pipeline::Actions

  class RemoveAttributeAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      attribute_name = @properties[:attribute_name]

      if reference_node.key?(attribute_name)
        reference_node.remove_attribute(attribute_name)
        add_info_msg("removed attribute #{reference_node.name}/@#{attribute_name}.")
        @status = UMPTG::Action.COMPLETED
      else
        add_warning_msg("attribute #{reference_node.name}/@#{attribute_name} not found.")
        @status = UMPTG::Action.FAILED
      end
    end
  end
end

