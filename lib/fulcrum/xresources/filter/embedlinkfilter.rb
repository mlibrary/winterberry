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

      embed_file_name = reference_node['data-fulcrum-embed-filename']
      img_node_list = reference_node.xpath(".//*[local-name()='img']")

      resource_name_list = []
      resource_name_list << embed_file_name unless embed_file_name.nil? or embed_file_name.strip.empty?
      img_node_list.each do |img_node|
        src = img_node["src"]
        if src.nil? or src.strip.empty?
          action_list << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: "#{reference_node.name}: image with no @src value"
               )
          next
        end
        resource_name_list << src
      end

      case
      when resource_name_list.count == 0
        # No resource references found.
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 error_message: "#{reference_node.name}: no resource reference found"
             )
      when resource_name_list.count > 1
        # Multiple resource references found.
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 warning_message: "#{reference_node.name}: multiple resource references found"
             )
      else
        # One resource reference found.
        caption_node = reference_node.xpath("./*[local-name()='figcaption']").first
        if caption_node.nil?
          action_list << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: \
                     "#{reference_node.name}: added figcaption element for #{resource_name_list.first}"
               )
          caption_text = manifest.fileset_caption(resource_name_list.first)
          frag = reference_node.parse("<figcaption><p>#{caption_text}</p></figcaption>")
          reference_node.add_child(frag)
          caption_node = reference_node.xpath(".//*[local-name()='figcaption']").first
        end

        block_list = caption_node.xpath(".//*[local-name()='p' or local-name()='div']")

        case
        when block_list.count > 1
          action_list << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   error_message: \
                    "#{reference_node.name}: multi block caption for resource #{embed_file_name}"
               )
        when img_node_list.count > 0
          # Image @src contains the resource reference.
          # If a caption exists, add link.
          link_markup = manifest.fileset_link_markup(
                  resource_name_list.first
                )

          if block_list.count > 0
            action_node = block_list.last
            container = UMPTG::XML::Pipeline::Actions::EmbedAction.default_container(
                        caption_node,
                        "span"
                    )
          else
            action_node = caption_node
            container = UMPTG::XML::Pipeline::Actions::EmbedAction.default_container(
                        caption_node,
                        "p"
                    )
          end
          container.add_child(link_markup)

          action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                   name: name,
                   reference_node: action_node,
                   action: :add_child,
                   markup: container.to_xml,
                   info_message: "#{reference_node.name}: links for resources #{resource_name_list.join(',')}"
               )
        else
          # @data-fulcrum-embed-filename attribute contains
          # the additional resource reference. If caption
          # exists, use text as link content.
          caption_markup = block_list.count > 0 ? \
                block_list.first.inner_html : caption_node.inner_html
          link_markup = manifest.fileset_link_markup(
                  resource_name_list.first,
                  caption_markup
                )

          container = UMPTG::XML::Pipeline::Actions::EmbedAction.default_container(
                      caption_node,
                      "p"
                  )
          container.add_child(link_markup)

          action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                   name: name,
                   reference_node: caption_node,
                   action: :replace_content,
                   markup: container.to_xml,
                   info_message: "#{reference_node.name}: links for resources #{resource_name_list.join(',')}"
               )
        end
      end
      return action_list
    end
  end
end
