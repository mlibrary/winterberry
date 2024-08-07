module UMPTG::XML::Pipeline::Actions

  class StripAttributeValueAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      attribute_name = @properties[:attribute_name]

      reference_node[attribute_name] = reference_node[attribute_name].strip
      add_info_msg("stripped attribute #{attribute_name} for element #{reference_node.name}")

      @status = UMPTG::Action.COMPLETED
    end
  end
end

