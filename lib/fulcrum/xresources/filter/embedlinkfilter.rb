module UMPTG::Fulcrum::XResources::Filter

  class EmbedLinkFilter < UMPTG::Fulcrum::Filter::ManifestFilter

    XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    ]
    SXPATH

    XPATH1 = <<-SXPATH
    //*[
    local-name()='figure'
    and (
    @data-fulcrum-embed-filename or count(.//*[local-name()='img']) > 0
    )
    ]
    SXPATH

    FORMAT_STR = <<-FSTR
    <p  data-fulcrum-embed-caption-filename="%s"
        data-fulcrum-embed-caption-field="%s"
        data-fulcrum-embed-caption-link="%s"/>
    FSTR

    CLASS_FORMAT_STR = <<-CFSTR
    <p class="%s"
        data-fulcrum-embed-caption-filename="%s"
        data-fulcrum-embed-caption-field="%s"
        data-fulcrum-embed-caption-link="%s"/>
    CFSTR

    def initialize(args = {})
      args[:name] = :embed_link unless args.key?(:name)
      args[:xpath] = XPATH
      super(args)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # figure element

      action_list = []

      figure_node = reference_node.dup
      caption_node = figure_node.xpath("./*[local-name()='figcaption']").first

      embed_file_name = figure_node['data-fulcrum-embed-filename']
      embed_file_name = embed_file_name.nil? ? "" : embed_file_name.strip

      img_node_list = reference_node.xpath(".//*[local-name()='img']")

      resource_node_list = []
      resource_node_list << figure_node unless embed_file_name.empty?
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
        resource_node_list << img_node
      end
      resource_name_list = resource_node_list.collect do |r|
        r["data-fulcrum-embed-filename"] if r.name == "figure"
        r["src"] if r.name == "img"
      end

      if resource_node_list.count == 0
        # No resource references found.
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 error_message: "#{reference_node.name}: no resource references found"
             )
      else
        if resource_node_list.count > 1
          # Multiple resource references found.
          action_list << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: "#{reference_node.name}: multiple resource references found #{resource_name_list.join(',')}"
               )
        end

        # One or more resource references found.
        caption_added = false
        if caption_node.nil?
          action_list << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: \
                     "#{reference_node.name}: added figcaption element for #{figure_node}"
               )
          figure_node.add_child("<figcaption/>")
          caption_node = figure_node.xpath(".//*[local-name()='figcaption']").first
          caption_added = true
        end
        block_list = caption_node.xpath(".//*[local-name()='p' or local-name()='div']")

        caption_field = reference_node["data-fulcrum-embed-caption-field"]
        caption_field = caption_field.strip.downcase unless caption_field.nil?
        caption_link = reference_node["data-fulcrum-embed-caption-link"]
        caption_link = (caption_link.strip.downcase == "true") unless caption_link.nil?

        resource_node_list.each do |resource_node|
          next if caption_field == "none"

          reference_name = resource_node.name == "img" ? \
                    resource_node["src"] : \
                    resource_node["data-fulcrum-embed-filename"]
          resource_name = manifest.fileset_file_name(reference_name)

          cf = caption_field.nil? ? "caption" : caption_field
          cl = caption_link.nil? ? false : caption_link
          if caption_added

            if caption_field.nil? and caption_link.nil?
              caption_node.add_child(CLASS_FORMAT_STR % ["default-media-display", resource_name, cf, "true"])
              caption_node.add_child(CLASS_FORMAT_STR % ["enhanced-media-display", resource_name, cf, cl])
            else
              caption_node.add_child(FORMAT_STR % [resource_name, cf, cl])
            end
          else
            block_list.each {|n| n.add_class("enhanced-media-display") }
            caption_node.add_child(CLASS_FORMAT_STR % ["default-media-display", resource_name, cf, "true"])
          end
          figure_node.remove_attribute("style")
        end
        action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                 name: name,
                 reference_node: reference_node,
                 action: :replace_node,
                 markup: figure_node.to_xml,
                 info_message: "#{reference_node.name}: links for resources #{resource_name_list.join(',')}"
             )

=begin
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
        figure_node = reference_node.dup
        caption_node = figure_node.xpath("./*[local-name()='figcaption']").first

        puts "resources:#{resource_name_list.join(',')}"
        if !embed_file_name.empty?
          block_list = []
        else
          if caption_node.nil?
            action_list << UMPTG::XML::Pipeline::Action.new(
                     name: name,
                     reference_node: reference_node,
                     warning_message: \
                       "#{reference_node.name}: added figcaption element for #{resource_name_list.first}"
                 )
            figure_node.add_child("<figcaption/>")
            caption_node = figure_node.xpath(".//*[local-name()='figcaption']").first
          end
          block_list = caption_node.xpath(".//*[local-name()='p' or local-name()='div']")
        end

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
          action_node.add_child(container)

          action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                   name: name,
                   reference_node: reference_node,
                   action: :replace_node,
                   markup: figure_node.to_xml,
                   info_message: "#{reference_node.name}: links for resources #{resource_name_list.join(',')}"
               )
        else
          # @data-fulcrum-embed-filename attribute contains
          # the additional resource reference.
          caption_field = reference_node["data-fulcrum-embed-caption-field"]
          caption_field = caption_field.nil? ? "" : caption_field.strip.downcase
          caption_link = reference_node["data-fulcrum-embed-caption-link"]
          caption_link = caption_link.nil? ? false : \
                (caption_link.strip.empty? or caption_link.strip.downcase == "true")
          if !caption_link \
                and (caption_field == "" or caption_field == "caption") \
                and (caption_node.nil? or caption_node.inner_html.strip.empty?)
            # Fulcrum UnpackJob should handle these cases.
            puts "Fulcrum"
          else
            figure_node.add_child("<figcaption/>") if caption_node.nil?
            caption_node = figure_node.xpath("./*[local-name()='figcaption']").first

            if caption_node.inner_html.strip.empty?
              caption_text = caption_field == "title" ? \
                    manifest.fileset_title(embed_file_name) : \
                    manifest.fileset_caption(embed_file_name)

              if caption_link
                caption_link = manifest.fileset_link_markup(embed_file_name, caption_text)
                caption_markup = "<p class=\"default-media-display\">#{caption_link}</p>" +
                                 "<p class=\"enhanced-media-display\">#{caption_text}</p>"
              else
                caption_markup = "<p>#{caption_text}</p>"
              end

              caption_node.add_child(caption_markup)
              action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                       name: name,
                       reference_node: reference_node,
                       action: :replace_node,
                       markup: figure_node.to_xml,
                       info_message: "#{reference_node.name}: links for resources #{resource_name_list.join(',')}"
                   )
            else
              node_list = reference_node.xpath("./*[local-name()='figcaption']//*[@data-fulcrum-embed-caption-field or @data-fulcrum-embed-caption-link]")
              node_list.each do |node|
                caption_field = node["data-fulcrum-embed-caption-field"]
                caption_field = caption_field.nil? ? "" : caption_field.strip.downcase
                caption_link = node["data-fulcrum-embed-caption-link"]
                caption_link = caption_link.nil? ? false : \
                      (caption_link.strip.empty? or caption_link.strip.downcase == "true")

                caption_text = caption_field == "title" ? \
                      manifest.fileset_title(embed_file_name) : \
                      manifest.fileset_caption(embed_file_name)

                puts "caption_link:#{caption_link}"
                if caption_link
                  caption_markup = manifest.fileset_link_markup(embed_file_name, caption_text)
                else
                  caption_markup = caption_text
                end

                new_node = node.dup
                new_node.add_child(caption_markup)
                caption_markup = new_node.to_xml
                #puts "caption_markup:#{caption_markup}"
                action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                         name: name,
                         reference_node: node,
                         action: :replace_node,
                         markup: caption_markup,
                         info_message: "#{reference_node.name}: links for resources #{resource_name_list.join(',')}"
                     )
              end
            end
          end
=end

=begin
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
=end
      end
      return action_list
    end
  end
end
