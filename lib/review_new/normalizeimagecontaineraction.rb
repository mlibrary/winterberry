module UMPTG::Review

  class NormalizeImageContainerAction < NormalizeAction

    def process(args = {})
      super(args)

      node_name = @action_node.name

=begin
      @action_node.name = "div"
      add_info_msg("image: \"#{@resource_path}\" converted image container from #{node_name} to #{@action_node.name}.")
=end
      #@action_node.replace(@action_node.children)
      @action_node.children.each do |n|
        @action_node.add_previous_sibling(n)
      end
      @action_node.remove
      add_info_msg("image: \"#{@resource_path}\" removed image container #{node_name}.")

      @status = NormalizeAction.NORMALIZED
    end
  end
end
