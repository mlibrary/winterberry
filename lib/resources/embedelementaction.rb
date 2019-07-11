class EmbedElementAction < Action
  def process()
    img_node = @action_args[:resource_img]
    resource = @action_args[:resource]
    resource_node = resource.resource_node

    if resource_node.node_name == "p"
      # Not sure about this. epubcheck complains about ./span/div
      # so, attempt to convert the 'p' to 'div'.
      # See how this goes.
      resource_node.node_name = "div"
    end

    emb_fragment = embed_fragment

    # May have an issue if the img_node has @{id,style,class}
    # Wrap a div around both containers and add these attrs?
    def_container = default_container
    img_node.add_next_sibling(def_container)
    def_container.add_child(img_node)

    emb_container = embed_container
    emb_container.add_child(embed_fragment)

    def_container.add_next_sibling(emb_container)

    return true
  end
end