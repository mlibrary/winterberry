module UMPTG::XML::Pipeline::Actions

  class SetAttributeValueAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      attribute_name = @properties[:attribute_name]
      if attribute_name.nil? or attribute_name.empty?
        add_error_msg("missing attribute name")
        @status = Action.FAILED
        return
      end

      attribute_value = @properties[:attribute_value]
      attribute_append = @properties.key?(:attribute_append) ? @properties[:attribute_append] : false

      attribute_value = attribute_value.nil? ? "" : attribute_value.strip

      current_attribute_value = reference_node[attribute_name].nil? ? "" : reference_node[attribute_name].strip
      if attribute_append
        current_attribute_value_list = current_attribute_value.split(' ')
        unless current_attribute_value_list.include?(attribute_value)
          current_attribute_value_list << attribute_value
          reference_node[attribute_name] = current_attribute_value_list.join(' ')
          @status = Action.COMPLETED
        end
      else
        reference_node[attribute_name] = attribute_value
        @status = NormalizeAction.NORMALIZED
      end
      add_info_msg("set attribute \"#{attribute_name}\" to value \"#{reference_node[attribute_name]}\" for element #{reference_node.name}") \
          if @status == Action.COMPLETED
    end
  end
end

