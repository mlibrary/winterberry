module UMPTG::Fulcrum::XResources::Filter

  class EmbedLinkFilter < UMPTG::Fulcrum::Filter::ManifestFilter

    EMBED_XPATH = <<-SXPATH
    //*[
    @data-fulcrum-embed-filename
    ]
    SXPATH

    FIGURE_EMBED_XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    or @data-fulcrum-embed-filename
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
    <p  data-fulcrum-embed-filename="%s"
        data-fulcrum-embed-caption-field="%s"
        data-fulcrum-embed-caption-link="%s"/>
    FSTR

    CLASS_FORMAT_STR = <<-CFSTR
    <p class="%s"
        data-fulcrum-embed-filename="%s"
        data-fulcrum-embed-caption-field="%s"
        data-fulcrum-embed-caption-link="%s"/>
    CFSTR

    def initialize(args = {})
      args[:name] = :embed_link unless args.key?(:name)
      process_figures = args[:process_figures]
      process_figures = true if process_figures.nil?
puts "process_figures:#{process_figures}"
      args[:xpath] = process_figures ? FIGURE_EMBED_XPATH : EMBED_XPATH
      super(args)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # figure element

      action_list = []

      case reference_node.name
      when "figure"
        action_list = create_figure_actions(reference_node)
      else
        action_list = create_element_actions(reference_node)
      end

      return action_list
    end

    private

    def create_figure_actions(reference_node)
      fragment_node = reference_node.dup

      action_list = []
      caption_node = fragment_node.xpath("./*[local-name()='figcaption']").first

      embed_file_name = fragment_node['data-fulcrum-embed-filename']
      embed_file_name = embed_file_name.nil? ? "" : embed_file_name.strip

      img_node_list = reference_node.xpath(".//*[local-name()='img']")

      resource_node_list = []
      resource_node_list << fragment_node unless embed_file_name.empty?
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
                     "#{reference_node.name}: added figcaption element for #{fragment_node}"
               )
          fragment_node.add_child("<figcaption class=\"figcaption\"/>")
          caption_node = fragment_node.xpath(".//*[local-name()='figcaption']").first
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
          fragment_node.remove_attribute("style")
        end

        caption_node.xpath(".//*[@data-fulcrum-embed-filename]").each do |node|
          insert_metadata(node)
        end
        action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                 name: name,
                 reference_node: reference_node,
                 action: :replace_node,
                 markup: fragment_node.to_xml,
                 info_message: "#{reference_node.name}: links for resources #{resource_name_list.join(',')}"
             )
      end
      return action_list
    end

    def create_element_actions(reference_node)
      fragment_node = reference_node.dup

      action_list = []
      node = insert_metadata(fragment_node)
      action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
               name: name,
               reference_node: reference_node,
               action: :replace_node,
               markup: node.to_xml,
               info_message: "#{reference_node.name}: links for resources #{fragment_node.name}"
           )
      return action_list
    end

    def insert_metadata(node)
      resource_name = node["data-fulcrum-embed-filename"]
      field = node["data-fulcrum-embed-caption-field"]
      #link = node["data-fulcrum-embed-caption-link"]
      link = node.name == "span" ? "true" : node["data-fulcrum-embed-caption-link"]

      case field
      when "caption"
        content = manifest.fileset_caption(resource_name)
      when "title"
        content = manifest.fileset_title(resource_name)
      else
        content = node.inner_html
      end
      markup = link == "true" ? manifest.fileset_link_markup(resource_name, content) : content

      node.remove_attribute("data-fulcrum-embed-filename")
      node.remove_attribute("data-fulcrum-embed-caption-field")
      node.remove_attribute("data-fulcrum-embed-caption-link")

      case node.name
      when "span"
        node = Nokogiri::XML::DocumentFragment.parse(markup)
      else
        node.add_child(markup)
      end
      return node
    end

  end
end
