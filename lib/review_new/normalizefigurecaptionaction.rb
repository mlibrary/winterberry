module UMPTG::Review

  class NormalizeFigureCaptionAction < NormalizeAction

    def process(args = {})
      super(args)

      cap_list = @properties[:cap_list]
      nested_node = cap_list.first.document.create_element("figcaption")
      cap_list.first.add_previous_sibling(nested_node)
      cap_list.each do |node|
        nested_node.add_child(node)
      end
=begin
      node_name = @action_node.name
      @action_node.name = "figcaption"
      add_info_msg("image: \"#{@resource_path}\" converted figure caption from #{node_name} to #{@action_node.name}.")
=end

      @status = NormalizeAction.NORMALIZED
    end
  end
end
