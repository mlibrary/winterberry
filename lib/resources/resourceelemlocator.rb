class ResourceElemLocator < ResourceLocator

  def find_resources(doc)
    doc.xpath("//*[local-name()='div' and @class='fig']")
  end

  def get_resource_path(options)
    resource_marker_node = options[:resource_marker]
    resource_actions = options[:resource_actions]

    str = resource_marker_node.xpath(".//*[local-name()='img']/@src")
    resource_path = File.basename(str.text.strip) unless str == nil

    if resource_actions != nil
      action = resource_actions.find { |row|
                      row['file_name'] == resource_path
                    }
      if action != nil
        resource_path = action['resource_name']
      end
    end
    resource_path
  end


  def get_reference_node(options)
    options[:resource_marker]
  end

  def replace_node(resource_marker_node)
    return false
  end
end
