module UMPTG::Fulcrum::XResources::Filter

  class EmbedLinkFilter < UMPTG::Fulcrum::Filter::ManifestFilter

    XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    and (
    @data-fulcrum-embed-filename or count(.//*[local-name()='img']) > 0
    )
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :embed_link unless args.key?(:name)
      args[:xpath] = XPATH
      super(args)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # figure element

      action_list = []
      caption_node = reference_node.xpath("./*[local-name()='figcaption']").first
      if caption_node.nil?
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 error_message: "#{reference_node.name}: figcaption element not found"
             )
      else
        resource_name_list = []
        embed_file_name = reference_node['data-fulcrum-embed-filename']
        resource_name_list << embed_file_name unless embed_file_name.nil? or embed_file_name.strip.empty?

        reference_node.xpath(".//*[local-name()='img']").each do |img_node|
          src = img_node["src"]
          resource_name_list << src unless src.nil? or src.strip.empty?
        end

        markup_list = []
        resource_name_list.each do |rname|
          link_markup = manifest.fileset_link_markup(rname)

          markup_list << link_markup unless link_markup.strip.empty?
        end

        action_node = caption_node
        container_name = "p"
        container = UMPTG::XML::Pipeline::Actions::EmbedAction.default_container(
                      action_node,
                      container_name
                  )
        container.add_child(markup_list.join)

        action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                 name: name,
                 reference_node: action_node,
                 action: :add_child,
                 markup: container.to_xml,
                 info_message: "#{reference_node.name}: links needed for resources #{resource_name_list.join(',')}"
             )
      end
      return action_list
    end
  end
end
