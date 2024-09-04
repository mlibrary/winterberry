module UMPTG::Fulcrum::Resources::Filter

  class ResourceReferenceFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='audio' or local-name()='video'
    ]/*[
    local-name()='source'
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :resource_reference
      args[:xpath] = XPATH
      super(args)
    end

    def create_actions(args = {})
      a = args.clone

      # source element
      reference_node = a[:reference_node]
      parent_node = reference_node.parent

      action_list = []

      reference_path = reference_node["src"]
      if reference_path.nil? or reference_path.strip.empty?
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 warning_message: \
                   "#{parent_node.name}: missing reference path"
             )
      else
        reference_container = reference_node.document.create_element("figure", :class => "enhanced-media-display")
        embed_filename = File.basename(reference_path)
        reference_container["data-fulcrum-embed-filename"] = embed_filename

        action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                 name: name,
                 reference_node: parent_node,
                 action: :replace_node,
                 markup: reference_container.to_xml,
                 info_message: "#{parent_node.name}: replace with #{reference_container.name}/@data-fulcrum-embed-filename=\"#{embed_filename}\"."
             )
      end

      return action_list
    end
  end
end
