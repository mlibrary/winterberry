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
        emb_container.add_child(emb_fragment)

        reference_container.add_next_sibling(emb_container)
        reference_container.remove

        # Action completed.
        @status = Action.COMPLETED
        return
      end

      # Action failed.
      @status = Action.FAILED
    end
  end
end
