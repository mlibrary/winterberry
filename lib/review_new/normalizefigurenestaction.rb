module UMPTG::Review

  class NormalizeFigureNestAction < NormalizeAction

    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      caption_node = @properties[:caption_node]
      caption_location = @properties[:caption_location]
      reference_container_node = @properties[:reference_container_node]

      nested_node = reference_container_node.document.create_element("figure")
      reference_container_node.add_previous_sibling(nested_node)
      case caption_location
      when :caption_after
        reference_container_node.children.each do |c|
          nested_node.add_child(c)
        end
        #nested_node.add_child(reference_container_node)
        #nested_node.add_child(reference_node)
        nested_node.add_child(caption_node)
      when :caption_before
        nested_node.add_child(caption_node)
        reference_container_node.children.each do |c|
          nested_node.add_child(c)
        end
        #nested_node.add_child(reference_container_node)
        #nested_node.add_child(reference_node)
      end
      reference_container_node.remove

      add_info_msg("#{@reference_node.name}: \"#{@resource_path}\": nest #{nested_node.name} #{caption_location} #{caption_node.name}.")

      @status = NormalizeAction.NORMALIZED
    end
  end
end
