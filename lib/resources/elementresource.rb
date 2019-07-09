class ElementResource < Resource
  def process()
    node_list = resource_node_list
    node_list.each do |node|
      spath = src_path(node)
      action = resource_action(spath)
      path = action['resource_name']
      metadata = resource_metadata(path)
      puts "#{action['resource_action']}: #{spath} => #{path}"
      element_action = ElementActionFactory.create(node, action)
      element_action.process(:resource_metadata => metadata) unless element_action == nil
    end

    if @resource_node.element_children.count == 0
      @resource_node.remove
    end
  end

  def resource_node_list
    @resource_node.xpath(".//*[local-name()='img']")
  end

  def src_path(resource_node)
    src_attr = resource_node.attribute("src")
    File.basename(src_attr.value.strip)
  end

  def resource_action(path)
    if @resource_actions != nil
      action = @resource_actions.find { |row|
                      row['file_name'] == path
                    }
      return action
    end
    @default_action
  end
end