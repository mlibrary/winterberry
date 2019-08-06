class ElementResource < Resource
  def create_actions
    options = @resource_args[:options]

    action_list = []
    node_list = resource_node_list
    node_list.each do |node|
      spath = src_path(node)
      action = resource_action(spath)
      path = action['resource_name']
      metadata = resource_metadata(path)

      if metadata != nil
        action = ElementActionFactory.create(
                    :resource => self,
                    :resource_action => action,
                    :resource_img => node,
                    :resource_metadata => metadata
                    )
        action_list << action unless action == nil
      end
    end

    if @resource_node.element_children.count == 0
      @resource_node.remove
    end

    return action_list
  end

  def resource_node_list
    @resource_node.xpath(".//*[local-name()='img']")
  end

  def src_path(resource_node)
    src_attr = resource_node.attribute("src")
    #File.basename(src_attr.value.strip)
    src_attr.value.strip
  end

  def resource_action(path)
    c_resource_action('file_name', path)
  end
end