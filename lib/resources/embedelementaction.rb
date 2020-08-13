class EmbedElementAction < Action
  def process()
    if reference_container.node_name == "p"
      # Not sure about this. epubcheck complains about ./span/div
      # so, attempt to convert the 'p' to 'div'.
      # See how this goes.
      reference_container.node_name = "div"
    end

    emb_fragment = embed_fragment()
    if emb_fragment.nil?
      @status = Action.FAILED
      return
    end

    # May have an issue if the img_node has @{id,style,class}
    # Wrap a div around both containers and add these attrs?
    if reference_node.parent.name == 'div'
      def_container = reference_node.parent
    else
      def_container = default_container
      reference_node.add_next_sibling(def_container)
      def_container.add_child(reference_node)
    end

    emb_container = embed_container()
    emb_container.add_child(emb_fragment)

    def_container.add_next_sibling(emb_container)

    @status = Action.COMPLETED
  end
end