module UMPTG::Review

  class RemoveAttributeAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      attribute_name = @properties[:attribute_name]

      if reference_node.key?(attribute_name)
        reference_node.remove_attribute(attribute_name)
        add_info_msg("#{reference_node.name}: remove attribute #{attribute_name}.")
        @status = NormalizeAction.NORMALIZED
      else
        add_info_msg("#{reference_node.name}: attribute #{attribute_name} not found.")
        @status = Action.FAILED
      end
    end
  end
end

