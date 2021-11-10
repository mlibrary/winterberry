module UMPTG::Review

  class RemoveAttributeAction < Action
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      attribute_name = @properties[:attribute_name]

      if reference_node.key?(attribute_name)
        reference_node.remove_attribute(attribute_name)
        add_info_msg("#{reference_node.name}: remove attribute #{attribute_name}.")
        @status = Action.COMPLETED
      else
        add_info_msg("#{reference_node.name}: attribute #{attribute_name} not found.")
        @status = Action.FAILED
      end
    end
  end
end

