module UMPTG::Review

  class NormalizeFigureNestAction < NormalizeAction

    def process(args = {})
      super(args)

      caption_node = @properties[:caption_node]
      caption_location = @properties[:caption_location]
      reference_container_node = @properties[:reference_container_node]

      nested_node = @reference_node.document.create_element("figure")
      reference_container_node.add_previous_sibling(nested_node)
      case caption_location
      when :caption_after
        nested_node.add_child(reference_container_node)
        nested_node.add_child(caption_node)
      when :caption_before
        nested_node.add_child(caption_node)
        nested_node.add_child(reference_container_node)
      end
      add_info_msg("#{@reference_node.name}: \"#{@reference_node['src']}\": nest #{nested_node.name} #{caption_location} #{caption_node.name}.")

      @status = NormalizeAction.NORMALIZED
    end
  end
end
