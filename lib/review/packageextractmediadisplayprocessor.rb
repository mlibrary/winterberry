module UMPTG::Review

  # Class processes each resource reference found within XML content.
  class PackageExtractMediaDisplayProcessor < EntryProcessor

    RESOURCE_REFERENCE_XPATH = <<-SXPATH
    //*[
    local-name()='manifest'
    ]/*[
    local-name()='item'
    and (
    contains(concat(' ',@properties,' '),' remote-resources ')
    or @id='fulcrum_default'
    )
    ]
    SXPATH

    # Processing parameters:
    #   :selector               Class for selecting resource references
    #   :logger                 Log messages
    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: RESOURCE_REFERENCE_XPATH
            )
      super(args)
    end

    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      reference_action_list = []
      unless @selector.nil? or xml_doc.nil?
        reference_list = @selector.references(xml_doc)
        reference_list.each do |reference_node|
          case
          when reference_node.key?("properties")
            reference_action_list << RemoveAttributeAction.new(
                        reference_node: reference_node,
                        attribute_name: 'properties'
                      )
          when reference_node['id'] == 'fulcrum_default'
            reference_action_list << RemoveElementAction.new(
                        reference_node: reference_node,
                        action_node: reference_node
                      )
          end
        end
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end
  end
end
