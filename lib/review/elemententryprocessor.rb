module UMPTG::Review
  class ElementEntryProcessor < EntryProcessor
    attr_reader :container_xpath, :child_xpath

    def initialize(args = {})
      super(args)

      @container_elements = @properties[:container_elements]
      raise "Error: no container elements specified" if @container_elements.nil?

      @child_elements = @properties[:child_elements]

      @container_xpath = "//*[" +
             @container_elements.collect {|x| "local-name()='#{x}'"}.join(' or ') + \
         "]"

      if @child_elements.empty?
        @child_xpath = nil
      else
        @child_xpath = ".//*[" + \
                    @child_elements.collect {|x| x.include?(':') ? "name()='#{x}'" : "local-name()='#{x}'"}.join(' or ') + \
                "]"
      end
    end

    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      reference_action_list = []
      unless xml_doc.nil?
        container_list = xml_doc.xpath(@container_xpath)
        unless container_list.empty?
          container_list.each_with_index do |container_node,ndx|
            container_name = container_node.namespace.prefix ?
                "#{container_node.namespace.prefix}:#{container_node.name}" : container_node.name
            container_id = container_node.key?("id") ? "\"#{container_node['id']}\"" : "\##{ndx+1}"

            reference_action_list += new_action(
                      name: name,
                      reference_node: container_node,
                      info_message: "#{container_name} #{container_id} found."
                    )

            child_list = container_node.xpath(@child_xpath)
            element_exist = @child_elements.to_h {|x| [x,nil]}
            unless child_list.empty?
              child_list.each do |child_node|
                element_name = child_node.namespace.prefix ?
                    "#{child_node.namespace.prefix}:#{child_node.name}" : child_node.name
                element_exist[element_name] = child_node
              end
            end

            element_exist.each do |e,n|
              list = new_action(
                        name: name,
                        reference_node: n,
                        container_node: container_node
                      )
              if n.nil?
                list.first.add_warning_msg("#{container_name} #{container_id}: element #{e} not found.")
              else
                list.first.add_info_msg("#{container_name} #{container_id}: element #{e} found.")
              end
              reference_action_list += list
            end
          end
        end
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end
  end
end
