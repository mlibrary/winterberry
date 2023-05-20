module UMPTG::Review

  # Class processes each resource reference found within XML content.
  class ResourceEmbedProcessor < EntryProcessor
    attr_accessor :manifest

    RESOURCE_REFERENCE_XPATH = <<-SXPATH
    //*[
    local-name()='img'
    or (local-name()='figure' and @data-fulcrum-embed-filename)
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
      @manifest = nil
    end

    def new_action(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      reference_node = args[:reference_node]

      reference_action_list = []
      case reference_node.name
      when 'img'
        resource_path = reference_node['src']
        msg = "#{reference_node.name}: found resource reference #{resource_path}"
      when 'figure'
        resource_path = reference_node['data-fulcrum-embed-filename']
        msg = "#{reference_node.name}: found additional resource reference #{resource_path}"
      end
      reference_action_list << EmbedElementAction.new(
                   name: name,
                   reference_node: reference_node,
                   resource_path: resource_path,
                   manifest: @manifest,
                   info_message: msg
                )
      return reference_action_list
    end
  end
end
