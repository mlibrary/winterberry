module UMPTG::Review

  class NormalizeFigureAction < NormalizeAction

    def process(args = {})
      super(args)

      node_name = @action_node.name

      @action_node.name = "figure"
      add_info_msg("image: \"#{@reference_node['src']}\" converted figure container from #{node_name} to #{@action_node.name}.")

      @status = NormalizeAction.NORMALIZED
    end
  end
end
