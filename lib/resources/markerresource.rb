class MarkerResource < Resource

  def process
    options = @resource_args[:options]

    result = false
    node_list = resource_node_list
    node_list.each do |node|
      path = resource_path(node)
      action = resource_action(path)
      metadata = resource_metadata(path)

      scan_report(
        :resource_action => action,
        :resource_metadata => metadata
        )

      if metadata != nil and options.execute
        marker_action = MarkerActionFactory.create(
                    :resource => self,
                    :resource_action => action,
                    :resource_img => node,
                    :resource_metadata => metadata
                    )
        result = marker_action.process() unless marker_action == nil

        # Catch any successes for now
        result = rc if rc == true
      end

    end

    return result
  end

  def resource_node_list
    @resource_node.xpath(".//comment()")
  end

  def resource_path(resource_node)
    resource_node.text.strip
    #resource_node.text.match("<img>([^\"]+)</img>")[1].strip
  end

  def resource_action(path)
    c_resource_action('resource_name', path)
  end

  def scan_report(args)
    action = args[:resource_action]
    metadata = args[:resource_metadata]

    puts "Resource: #{self.class}, #{action['resource_action']}: #{action['resource_name']}, metadata: #{metadata == nil ? "none" : "exists"}"
    #puts "Action:   #{action.class}"
    #puts "Metadata: #{metadata.class}"
  end
end