class ElementResource < Resource
  def process()
    options = @resource_args[:options]

    result = false
    node_list = resource_node_list
    node_list.each do |node|
      spath = src_path(node)
      action = resource_action(spath)
      path = action['resource_name']
      metadata = resource_metadata(path)

      scan_report(
        :resource_action => action,
        :resource_metadata => metadata
        )

      if metadata != nil and options.execute
        element_action = ElementActionFactory.create(
                    :resource => self,
                    :resource_action => action,
                    :resource_img => node,
                    :resource_metadata => metadata
                    )
        rc = element_action.process() unless element_action == nil

        # Catch any successes for now
        result = rc if rc == true
      end
    end

    if @resource_node.element_children.count == 0
      @resource_node.remove
    end

    return result
  end

  def resource_node_list
    @resource_node.xpath(".//*[local-name()='img']")
  end

  def src_path(resource_node)
    src_attr = resource_node.attribute("src")
    File.basename(src_attr.value.strip)
  end

  def resource_action(path)
    c_resource_action('file_name', path)
  end

  def scan_report(args)
    action = args[:resource_action]
    metadata = args[:resource_metadata]

    puts "Resource: #{self.class}, #{action['resource_action']}: #{action['file_name']} => #{action['resource_name']}, metadata: #{metadata == nil ? "none" : "exists"}"
    #puts "Action:   #{action.class}"
    #puts "Metadata: #{metadata.class}"
  end
end