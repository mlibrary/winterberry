module UMPTG::Review

  class NormalizeFigureCaptionAction < Action

    def process(args = {})
      super(args)

      node_name = @action_node.name
      @action_node.name = "figcaption"
      add_info_msg("Image:  #{@reference_node['src']} converted figure caption from #{node_name} to #{@action_node.name}.")

      @status = Action.COMPLETED
    end
  end
end
