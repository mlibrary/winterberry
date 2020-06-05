class EmbedMarkerAction < Action
  def process()
    resource = @action_args[:resource]
    resource_node = resource.resource_node

    emb_fragment = embed_fragment

    emb_container = embed_container
    unless emb_fragment.nil? or emb_container.nil?
      emb_container.add_child(emb_fragment)

      resource_node.add_next_sibling(emb_container)
      resource_node.remove
      @status = @@COMPLETED
      return
    end
    @status = @@FAILED
  end

  def to_s
    marker_action_to_s
  end
end