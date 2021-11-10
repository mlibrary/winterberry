module UMPTG::Review
  class ListProcessor < ElementEntryProcessor
    def initialize(args = {})
      args[:container_elements] = [ 'dl', 'ol', 'ul' ]
      args[:child_elements] = [ 'li' , 'dt', 'dd' ]
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

            child_list = container_node.xpath(@child_xpath)
            unless child_list.empty?
              child_list.each_with_index do |child_node,child_ndx|
                element_name = child_node.namespace.prefix ?
                    "#{child_node.namespace.prefix}:#{child_node.name}" : child_node.name
                child_id = child_node.key?("id") ? "\"#{child_node['id']}\"" : "\##{child_ndx+1}"

                list = new_action(
                          name: name,
                          reference_node: child_node,
                          container_node: container_node
                        )
                if child_node.xpath(".//*[local-name()='p']").empty?
                  list.first.add_warning_msg("#{container_name} #{container_id},item #{child_id}: element p not found.")
                else
                  list.first.add_warning_msg("#{container_name} #{container_id},item #{child_id}: element p found.")
                end
                reference_action_list += list
              end
            end
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
