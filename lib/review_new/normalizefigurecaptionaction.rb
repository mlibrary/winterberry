module UMPTG::Review

  class NormalizeFigureCaptionAction < NormalizeAction

    def process(args = {})
      super(args)

      node_name = @action_node.name
      @action_node.name = "figcaption"
      add_info_msg("image: \"#{@reference_node['src']}\" converted figure caption from #{node_name} to #{@action_node.name}.")

      @status = NormalizeAction.NORMALIZED
    end
  end
end
