class RemoveElementAction < Action
  def process(args)
    metadata = args[:resource_metadata]
    remove_resource(metadata)
  end

  def remove_resource(metadata)
    if false
      # For now, not removing captions
      next_sibling = @resource_node.next_element
      if next_sibling != nil and next_sibling.node_name == 'p'
        puts "next name: #{next_sibling.node_name}"
        klass_attr = next_sibling.attribute("class")
        klass = klass_attr == nil ? "" : klass_attr.text
        if klass == "image_caption"
          #next_sibling.remove
        end
      end
    end

   @resource_node.remove
  end
end