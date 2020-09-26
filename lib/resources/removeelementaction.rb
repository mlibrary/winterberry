module UMPTG::Resources

  class RemoveElementAction < Action
    def process()
=begin
      # For now, not removing captions
      container = resource_container.node_name == 'p' ? resource_container.parent : resource_container
      caption = container.xpath(".//*[local-name()='p' and (@class='image_caption' or @class='figh')]")
      if caption != nil
        caption.remove
      end
=end
     reference_node.remove
    end
  end
end
