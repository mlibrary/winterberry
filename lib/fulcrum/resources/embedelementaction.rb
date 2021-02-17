module UMPTG::Fulcrum::Resources

  # Class that inserts resource embed viewer markup into
  # XML content (image, video, audio).
  class EmbedElementAction < Action
    def process()
      if reference_container.node_name == "p"
        # Not sure about this. epubcheck complains about ./span/div
        # so, attempt to convert the 'p' to 'div'.
        # See how this goes.
        reference_container.node_name = "div"
      end

      # Retrieve the resource embed markup from the
      # Fulcrum resource metadata.
      emb_fragment = embed_fragment()
      if emb_fragment.nil?
        @status = Action.FAILED
        return
      end

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

      # Wrap the current resource XML markup with a container
      # that allows it to be visible when not in the Fulcrum reader.
      def_container = default_container
      reference_node.add_next_sibling(def_container)
      def_container.add_child(reference_node)

      # Insert new resource XML markup that will embed the
      # resource when viewed in the Fulcrum reader.
      emb_container = embed_container()
      emb_container.add_child(emb_fragment)

      def_container.add_next_sibling(emb_container)

      # Action completed.
      @status = Action.COMPLETED
    end
  end
end
