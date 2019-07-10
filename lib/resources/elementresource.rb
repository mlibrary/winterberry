class ElementResource < Resource
  def process()
    options = @resource_args[:options]

    node_list = resource_node_list
    node_list.each do |node|
      spath = src_path(node)
      action = resource_action(spath)
      path = action['resource_name']
      metadata = resource_metadata(path)

      if metadata == nil or options.do_scan
        scan_report(
          :resource_action => action,
          :resource_metadata => metadata
          )
      else
        element_action = ElementActionFactory.create(node, action)
        element_action.process(:resource_metadata => metadata) unless element_action == nil
      end
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
    action = @resource_actions.find { |row| row['file_name'] == path } \
              unless @resource_actions == nil
    return action unless action == nil

    return default_action(:resource_name => path, :file_name => path)
  end

  def scan_report(args)
    action = args[:resource_action]
    metadata = args[:resource_metadata]

    puts "Resource: #{self.class}, #{action['resource_action']}: #{action['file_name']} => #{action['resource_name']}, metadata: #{metadata == nil ? "none" : "exists"}"
    #puts "Action:   #{action.class}"
    #puts "Metadata: #{metadata.class}"
  end
end