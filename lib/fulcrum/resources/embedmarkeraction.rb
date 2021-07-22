module UMPTG::Fulcrum::Resources

  # Class that inserts additional resource embed viewer markup into
  # XML content (image, video, audio).
  class EmbedMarkerAction < Action
    def process()

     # Insert new resource XML markup that will embed the
     # resource when viewed in the Fulcrum reader.
     emb_fragment = embed_fragment

      emb_container = embed_container
      unless emb_fragment.nil? or emb_container.nil?

        # Wrap the current resource XML markup with a container
        # that allows it to be visible when not in the Fulcrum reader.
        def_container = default_container
        reference_node.add_next_sibling(def_container)
        def_container.add_child(reference_node)

        emb_container.add_child(emb_fragment)

        def_container.add_next_sibling(emb_container)

        # Action completed.
        @status = Action.COMPLETED
        return
      end

      # Action failed.
      @status = Action.FAILED
    end
  end
end
