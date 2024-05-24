module UMPTG::Fulcrum::Metadata::Filters

  class ResourceMetadataFilter < UMPTG::XML::Pipeline::Filter

    RESOURCE_XPATH = <<-SXPATH
    //*[
    local-name()='figure' and count(descendant::*[local-name()='figure'])=0
    ] | //*[
    local-name()='img' and count(ancestor::*[local-name()='figure'])=0
    ] | //*[
    @data-fulcrum-embed-filename and local-name()!='figure'
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :resource_metadata
      args[:xpath] = RESOURCE_XPATH
      super(args)
    end

    def create_actions(args = {})
      a = args.clone

      # Node could be one of the following:
      #   figure
      #   img with no figure parent
      #   span with @data-fulcrum-embed-filename
      reference_node = a[:reference_node]

      action_list = []
      if reference_node.key?("data-fulcrum-embed-filename")
        action = UMPTG::Fulcrum::Metadata::Actions::MarkerAction.new(
                             name: args[:name],
                             reference_node: reference_node
                             )
      else
        action = UMPTG::Fulcrum::Metadata::Actions::FigureAction.new(
            name: args[:name],
            reference_node: reference_node
            )
      end

      action_list << action
      return action_list
    end
  end
end