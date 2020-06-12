class ElementResource < Resource
  def create_actions
    options = @resource_args[:options]

    action_list = []
    node_list = resource_node_list
    node_list.each do |node|
      spath = src_path(node)
      resource_action = resource_action(spath)

      unless resource_action.nil?
        action = ElementActionFactory.create(
                    :resource => self,
                    :resource_action => resource_action,
                    :resource_img => node
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
    resource_action = @resource_actions.find {|a| a.reference == path }
    return resource_action unless resource_action.nil?

    reference = ResourceMapReference.new(:name => path)
    return ReferenceAction.new(
           :resource_map_action => ResourceMapAction.new(
                                       :reference => reference,
                                       :resource => nil,
                                       :type => @default_action_str
                                   ),
           :resource_metadata => nil
         )
  end
end