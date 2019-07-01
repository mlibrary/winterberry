class ResourceMarkerLocator < ResourceLocator

  def find_resources(doc)
    doc.xpath("//*[@class='rb_test' or @class='rbi_test']")
  end

  def get_resource_path(options)
    resource_marker_node = options[:resource_marker]

    str = resource_marker_node.xpath(".//comment()")
    #str.text.match("file=\"([^\"]+)\"")[1].strip
    str.text.match("<img>([^\"]+)</img>")[1].strip
  end

  def get_resource_action(options)
    resource_marker_node = options[:resource_marker]
    resource_actions = options[:resource_actions]

    resource_path = get_resource_path(options)
    if resource_actions != nil
      action = resource_actions.find { |row|
                      row['resource_name'] == resource_path
                    }
      return action unless action == nil
    end
    nil
  end

  def get_reference_node(options)
    resource_marker_node = options[:resource_marker]
    resource_actions = options[:resource_actions]

    resource_path = get_resource_path(:resource_marker => resource_marker_node)

    action = nil
    if resource_actions != nil
      action = resource_actions.find { |row|
                      row['resource_name'] == resource_path
                    }
    end

    if action != nil
      file_path = action['file_name']
      node_list =
            resource_marker_node.document.xpath("//*[@*[contains(.,'#{file_path}')]]")
      puts "file_path: #{file_path} count: #{node_list.count}"
      if node_list.count > 0
        # Just using first found for now. May support multiple
        # at a later date.
        ref_node = node_list[0]
        parent_node = ref_node.parent
        if parent_node != nil and parent_node.name == "figure"
          ref_node = parent_node
        end
        return ref_node
      end
    end

    get_previous_node(resource_marker_node)
  end

  def get_previous_node(resource_marker_node)
    reference_node = resource_marker_node.previous_element
    if false and reference_node != nil
      # Confirm that the marker path resides within the
      # reference markup.
      path = get_resource_path(resource_marker_node)
      r = reference_node.xpath(".//*[@*[contains(.,'#{path}')]]")
      if r.count > 0
        if r.count > 1
          puts "Found multiple instances of path in reference markup."
        end
        return reference_node
      end

      puts "Marker path (#{path}) not found within reference markup (#{reference_node})."
    end
    reference_node
  end

  def replace_node(resource_marker_node)
    klass_attr = resource_marker_node.attribute("class")
    klass = klass_attr == nil ? "" : klass_attr.value
    klass == "rbi_test"
  end
end
