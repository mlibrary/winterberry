require 'nokogiri'

class ReferenceProcessor

  @@SELECTION_XPATH = <<-SXPATH
//*[
(local-name()='p' and @class='fig')
or (local-name()='figure' and count(*[local-name()='p' and @class='fig'])=0)
or @class='rb'
or @class='rbi'
]
SXPATH

  def resource_actions(args = {})
		xml_doc = args[:xml_doc]
		raise "Error: XML document must be specified." if xml_doc.nil?

    resource_action_list = []
		refnode_list = xml_doc.xpath(@@SELECTION_XPATH)
		refnode_list.each do |refnode|
      resource_args = args.clone

      resource_args[:resource_node] = refnode

      reference_type = ReferenceProcessor.node_type(refnode)
      resource_args[:reference_type] = reference_type

      resource = Resource.new(resource_args)
      resource_args[:resource] = resource

      case reference_type
      when :element
        list = element_resource_actions(resource_args)
      when :marker
        list = marker_resource_actions(resource_args)
      else
        next
      end
      resource_action_list += list
	  end
    return resource_action_list
  end

  def process(resource_action)
    resource_action.process
  end

  private

	def self.node_type(node)
		attr = node.attribute("class")
		unless attr.nil?
		  attr = attr.text.downcase
		  return :marker if attr == "rb" or attr == "rbi"
		end
		return :element
	end

	def element_resource_actions(args)
    resource = args[:resource]
    refnode = resource.resource_node
    node_list = refnode.xpath(".//*[local-name()='img']")

    element_resource_action_list = []
    node_list.each do |node|
      src_attr = node.attribute("src")
      next if src_attr.nil?

      args[:resource_img] = node

      spath = src_attr.value.strip
      reference_action = resource.reference_action(spath)

      unless reference_action.nil?
        args[:resource_action] = reference_action

        case reference_action.action_str
        when "embed"
          resource_type = reference_action.resource_type
          resource_action = resource_type == 'interactive map' ? \
                  EmbedMapAction.new(args) : \
                  EmbedElementAction.new(args)
        when "link"
          resource_action = LinkElementAction.new(args)
        when "remove"
          resource_action = RemoveElementAction.new(args)
        when "none"
          resource_action = NoneAction.new(args)
        else
          puts "Warning: invalid element action #{reference_action.to_s}"
          resource_action = nil
        end

        element_resource_action_list << resource_action unless resource_action.nil?
      end
    end
    return element_resource_action_list
	end

	def marker_resource_actions(args)
    resource = args[:resource]
    refnode = resource.resource_node

    # Return the nodes that reference resources.
    # For marker callouts, this should be within
    # a XML comment, but not always the case.
    # NOTE: either display warning if no comment,
    # or just use the node content?
    node_list = refnode.xpath(".//comment()")
    node_list = [ refnode ] if node_list.nil? or node_list.empty?

    marker_resource_action_list = []
    node_list.each do |node|
      path = node.text.strip
      reference_action = resource.reference_action(path)

      args[:resource_img] = node

      unless reference_action.nil?
        args[:resource_action] = reference_action

        case reference_action.action_str
        when "embed"
          resource_action = EmbedMarkerAction.new(args)
        when "link"
          resource_action = LinkMarkerAction.new(args)
        when "none"
          resource_action = NoneAction.new(args)
        else
          puts "Warning: invalid marker action #{reference_action.action_str}"
          resource_action = nil
        end

        marker_resource_action_list << resource_action unless resource_action.nil?
      end
    end
    return marker_resource_action_list
  end
end