module UMPTG::Review
  class ElementEntryProcessor < EntryProcessor

    METADATA_ELEMENTS = [ 'dc:title', 'dc:creator', 'dc:language', 'dc:rights', 'dc:publisher', 'dc:identifier' ]

    def initialize(args = {})
      super(args)

      @elements = @properties[:selection_elements]
      raise "Error: no elements specified" if @elements.nil?
    end

    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      reference_action_list = []
      unless @selector.nil? or xml_doc.nil?

        reference_list = @selector.references(xml_doc)

        # For each reference element, determine the necessary actions.
        element_exist = @elements.to_h {|x| [x,nil]}
        reference_list.each do |refnode|
          element_name = refnode.namespace.prefix ?
              "#{refnode.namespace.prefix}:#{refnode.name}" : refnode.name
          element_exist[element_name] = refnode
        end

        element_exist.each do |e,n|
          list = new_action(
                    name: name,
                    reference_node: n
                  )
          if n.nil?
            list.first.add_warning_msg("Element #{e} not found.")
          else
            list.first.add_info_msg("Element #{e} found.")
          end
          reference_action_list += list
        end

        # Process all the Actions for this XML content.
        reference_action_list.each do |action|
          action.process()
        end
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end

    #
    #
    # Arguments:
    def new_action(args = {})
      return super(args)
    end
  end
end
