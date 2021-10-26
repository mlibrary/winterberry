module UMPTG::Review

  class NormalizeFigureNestAction < NormalizeFigureAction

    def process(args = {})
      super(args)

      #reference_node = @properties[:reference_node]
      #caption_node = @properties[:caption_node]
      caption_location = @properties[:caption_location]
      #reference_container_node = @properties[:reference_container_node]
      figure_container = @properties[:figure_container]
      sfig_obj = @properties[:sfig_obj]

      nested_node = figure_container.document.create_element("figure")
      sfig_obj[:img_list].first.add_previous_sibling(nested_node)

      props = @properties.clone
      props[:nested_node] = nested_node
      props[:normalize_caption_class] = args[:normalize_caption_class]

      case caption_location
      when :caption_after
        normalize_images(props)
        normalize_captions(props)
      when :caption_before
        normalize_captions(props)
        normalize_images(props)
      end

      @status = NormalizeAction.NORMALIZED
    end

    def normalize_images(args = {})
      figure_container = args[:figure_container]
      caption_location = args[:caption_location]
      sfig_obj = args[:sfig_obj]
      nested_node = args[:nested_node]

      sfig_obj[:img_list].each do |node|
        nested_node.add_child(node)
        add_info_msg("#{figure_container.name}: nest #{nested_node.name} #{caption_location} #{node.name}.")
      end
    end

    def normalize_captions(args = {})
      figure_container = args[:figure_container]
      caption_location = args[:caption_location]
      sfig_obj = args[:sfig_obj]
      nested_node = args[:nested_node]

      cap_container = nested_node.document.create_element("figcaption")
      nested_node.add_child(cap_container)
      sfig_obj[:cap_list].each do |node|
        args[:caption_node] = node
        NormalizeFigureAction.normalize_caption_class(args)

        cap_container.add_child(node)
        add_info_msg("#{figure_container.name}: nest #{nested_node.name} #{caption_location} #{node.name}.")
      end
    end
  end
end
