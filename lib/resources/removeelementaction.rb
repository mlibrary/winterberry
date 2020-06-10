class RemoveElementAction < Action
  def process()
    resource = @action_args[:resource]
    resource_node = resource.resource_node
    img_node = @action_args[:resource_img]

    if false
      # For now, not removing captions
      container = resource_node.node_name == 'p' ? resource_node.parent : resource_node
      caption = container.xpath(".//*[local-name()='p' and (@class='image_caption' or @class='figh')]")
      if caption != nil
        caption.remove
      end
    end

   img_node.remove
  end
end