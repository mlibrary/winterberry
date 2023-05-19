module UMPTG::Review

  # Class processes each resource reference found within XML content.
  class MediaConvertProcessor < EntryProcessor
    attr_accessor :manifest

    RESOURCE_REFERENCE_XPATH = <<-SXPATH
    //*[
    local-name()='audio'
    or local-name()='video'
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
      source_node = reference_node.xpath(".//*[local-name()='source']").first
      if source_node.nil? or source_node["src"].nil? or source_node["src"].strip.empty?
        reference_action_list << Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: "#{reference_node.name}: resource path missing"
                )
      else
        reference_action_list << NormalizeMarkerAction.new(
                   name: name,
                   reference_node: reference_node,
                   resource_path: source_node["src"].strip
                )
      end
      return reference_action_list
    end
  end
end
