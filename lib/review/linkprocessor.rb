module UMPTG::Review
  class LinkProcessor < ElementEntryProcessor
    def initialize(args = {})
      args[:container_elements] = [ 'a']
      args[:child_elements] = [ ]
      super(args)
    end

    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      reference_action_list = []
      unless xml_doc.nil?
        container_list = xml_doc.xpath(@container_xpath)
        unless container_list.empty?
          container_list.each_with_index do |container_node,container_ndx|
            container_name = container_node.namespace.prefix ?
                "#{container_node.namespace.prefix}:#{container_node.name}" : container_node.name
            container_id = container_node.key?("id") ? "\"#{container_node['id']}\"" : "\##{container_ndx+1}"

            list = new_action(
                      name: name,
                      reference_node: container_node
                    )

            id = container_node['id']
            target = container_node['target']
            title = container_node['title']
            href = container_node['href']
            content = container_node.text

            label = ""
            label = "(@id=\"#{id}\")" unless id.nil? or id.empty?
            label = "(@href=\"#{href}\")" if (id.nil? or id.empty?) and !(href.nil? or href.empty?)
            label = "(@target=\"#{target}\")" if (id.nil? or id.empty?) and (href.nil? or href.empty?) and !(target.nil? or target.empty?)

            list.first.add_info_msg("link #{label}: has title attribute") unless title.nil? or title.empty?
            list.first.add_warning_msg("link #{label}: has no title attribute") if title.nil? or title.empty?
            list.first.add_info_msg("link #{label}: has content") unless content.nil? or content.empty?
            list.first.add_warning_msg("link #{label}: has no content") if content.nil? or content.empty?

            reference_action_list += list
          end

          # Process all the Actions for this XML content.
          reference_action_list.each do |action|
            action.process()
          end
        end
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end
  end
end
