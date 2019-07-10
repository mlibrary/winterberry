class MarkerResource < Resource

  def process
    options = @resource_args[:options]

    node_list = resource_node_list
    node_list.each do |node|
      path = resource_path(node)
      action = resource_action(path)
      metadata = resource_metadata(path)

      if metadata == nil or options.do_scan
        scan_report(
          :resource_action => action,
          :resource_metadata => metadata
          )
      else
        marker_action = MarkerActionFactory.create(node, action)
        marker_action.process(:resource_metadata => metadata) unless marker_action == nil
      end
    end
  end

  def resource_node_list
    @resource_node.xpath(".//comment()")
  end

  def resource_path(resource_node)
    resource_node.text.strip
    #resource_node.text.match("<img>([^\"]+)</img>")[1].strip
  end

  def resource_action(path)
    action = @resource_actions.find { |row| row['resource_name'] == path } \
              unless @resource_actions == nil
    return action unless action == nil

    return default_action(:resource_name => path, :file_name => path)
  end

  def scan_report(args)
    action = args[:resource_action]
    metadata = args[:resource_metadata]

    puts "Resource: #{self.class}, #{action['resource_action']}: #{action['resource_name']}, metadata: #{metadata == nil ? "none" : "exists"}"
    #puts "Action:   #{action.class}"
    #puts "Metadata: #{metadata.class}"
  end
end