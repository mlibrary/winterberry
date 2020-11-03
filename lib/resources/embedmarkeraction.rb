module UMPTG::Resources

  class EmbedMarkerAction < Action
    def process()
      emb_fragment = embed_fragment

      emb_container = embed_container
      unless emb_fragment.nil? or emb_container.nil?
        emb_container.add_child(emb_fragment)

        reference_container.add_next_sibling(emb_container)
        reference_container.remove
        @status = Action.COMPLETED
        return
      end
      @status = Action.FAILED
    end
  end
end
