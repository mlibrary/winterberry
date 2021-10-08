module UMPTG::Review

  class NormalizeFigureNestAction < NormalizeAction

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

      case caption_location
      when :caption_after
        normalize_images(props)
        normalize_captions(props)
      when :caption_before
        normalize_captions(props)
        normalize_images(props)
      end


=begin
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
=end

      @status = NormalizeAction.NORMALIZED
    end

    def normalize_images(args = {})
      figure_container = @properties[:figure_container]
      caption_location = @properties[:caption_location]
      sfig_obj = args[:sfig_obj]
      nested_node = args[:nested_node]

      sfig_obj[:img_list].each do |node|
        nested_node.add_child(node)
        add_info_msg("#{figure_container.name}: nest #{nested_node.name} #{caption_location} #{node.name}.")
      end
    end

    def normalize_captions(args = {})
      figure_container = @properties[:figure_container]
      caption_location = @properties[:caption_location]
      sfig_obj = args[:sfig_obj]
      nested_node = args[:nested_node]

      cap_container = nested_node.document.create_element("figcaption")
      nested_node.add_child(cap_container)
      sfig_obj[:cap_list].each do |node|
        cap_container.add_child(node)
        add_info_msg("#{figure_container.name}: nest #{nested_node.name} #{caption_location} #{node.name}.")
      end
    end
  end
end
