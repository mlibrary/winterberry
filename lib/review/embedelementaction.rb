module UMPTG::Review

  # Class that inserts resource embed viewer markup into
  # XML content (image, video, audio).
  class EmbedElementAction < EmbedAction

    def process()
      resource_path = @properties[:resource_path]
      embed_fragment = @properties[:embed_fragment]

=begin
      if reference_container.node_name == "p"
        # Not sure about this. epubcheck complains about ./span/div
        # so, attempt to convert the 'p' to 'div'.
        # See how this goes.
        reference_container.node_name = "div"
      end
=end

      # Insert new resource XML markup that will embed the
      # resource when viewed in the Fulcrum reader.
      emb_container = EmbedAction.embed_container(reference_node)
      emb_container.add_child(embed_fragment)

      # May have an issue if the img_node has @{id,style,class}
      # Wrap a div around both containers and add these attrs?
=begin
      puts "#{__method__}:parent=#{reference_node.parent.name}"
      if reference_node.parent.name == 'div'
        def_container = reference_node.parent
      else
        def_container = default_container
        reference_node.add_next_sibling(def_container)
        def_container.add_child(reference_node)
      end
=end

      case reference_node.name
      when 'img'
        # Wrap the current resource XML markup with a container
        # that allows it to be visible when not in the Fulcrum reader.
        def_container = EmbedAction.default_container(reference_node)
        reference_node.add_next_sibling(def_container)
        def_container.add_child(reference_node)
        def_container.add_next_sibling(emb_container)
      when 'figure'
        figcaption_node = reference_node.xpath("./*[local-name()='figcaption']").first
        if figcaption_node.nil?
          reference_node.add_child(emb_container)
        else
          if reference_node.has_attribute?("data-fulcrum-embed-filename")
            emb_container.add_child(figcaption_node)
            reference_node.add_child(emb_container)
          else
            figcaption_node.add_previous_sibling(emb_container)
          end
        end
        reference_node.remove_attribute("data-fulcrum-embed-filename")
        # Setting this didn't seem to work. Got double resources embedded.
        #reference_node["data-fulcrum-embed"] = false
        reference_node.remove_attribute("style")
      else
        raise "embed for element #{reference_node.name} not implemented"
      end

=begin
      # TODO: add option for this? For globally enhanced
      # EPUBs, remove the default container leaving only
      # the enhanced container.
      def_container.remove
=end
      add_info_msg("embed resource for #{resource_path}")

      # Action completed.
      @status = NormalizeAction.NORMALIZED
    end
  end
end
