module UMPTG::Fulcrum::Metadata

  require_relative(File.join("..", "..", "..", "..", "lib", "xml", "pipeline"))

  class ResourceMetadataFilter < UMPTG::XML::Pipeline::Filter

    RESOURCE_XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    ] | *[
    local-name='img' and count(ancestor::*[local-name()='figure'])=0
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
      action_list << UMPTG::XML::Pipeline::Action.new(
              name: args[:name],
              reference_node: reference_node,
              info_message: "found resource element #{reference_node.name}"
              )

      img_node_list = []
      img_node_list << reference_node if reference_node.name == 'img'
      img_node_list += reference_node.xpath(".//*[local-name()='img']") \
              if reference_node.name == 'figure'

      img_node_list.each do |img_node|
        action_list << UMPTG::XML::Pipeline::Action.new(
                name: args[:name],
                reference_node: img_node,
                info_message: "processing element #{img_node.name}"
                )
      end

      return action_list
    end
  end
end