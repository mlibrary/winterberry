class ElementResource < Resource
  def process()
    node_list = resource_node_list
    node_list.each do |node|
      spath = src_path(node)
      action = resource_action(spath)
      path = action['resource_name']
      puts spath
      puts path
      puts action
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
    nil
  end
end