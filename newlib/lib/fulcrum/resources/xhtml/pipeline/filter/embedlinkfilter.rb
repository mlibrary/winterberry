module UMPTG::Fulcrum::Resources::XHTML::Pipeline::Filter

  class EmbedLinkFilter < UMPTG::Fulcrum::Filter::ManifestFilter

    EMBED_XPATH = <<-SXPATH
    //*[
    @data-fulcrum-embed-filename
    ]
    SXPATH

    FIGURE_EMBED_XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    or (@data-fulcrum-embed-filename and count(ancestor::*[local-name()='figure'])=0)
    or (local-name()='img' and count(ancestor::*[local-name()='figure'])=0)
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
      args[:name] = :xhtml_embed_link

      raise "manifest required" if args[:manifest].nil?

      process_figures = args[:process_figures]
      process_figures = true if process_figures.nil?
      args[:xpath] = process_figures ? FIGURE_EMBED_XPATH : EMBED_XPATH
      super(args)
    end

    def run(xml_doc, args = {})
      actions = super(xml_doc, args)

      unless actions.empty?
        reference_node = xml_doc.xpath(FulcrumCSSFilter.XPATH).first
        raise "unable to add Fulcrum CSS filter" if reference_node.nil?

        a = {
            reference_node: reference_node,
            markup: '<link href="../styles/fulcrum_default.css" rel="stylesheet" type="text/css"/>',
            info_message: "Fulcrum CSS filter must be added"
          }
        actions << UMPTG::XML::Pipeline::Actions::NormalizeInsertMarkupAction.new(a)
      end

      return actions
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # figure element

      action_list = []

      case reference_node.name
      when "figure"
        action_list = create_figure_actions(reference_node)
      when "img"
        action_list = create_img_actions(reference_node)
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

        resource_name_list = []
        resource_node_list.each do |resource_node|
          reference_name = resource_node.name == "img" ? \
                    resource_node["src"] : \
                    resource_node["data-fulcrum-embed-filename"]
          resource_name = manifest.fileset_file_name(reference_name)
          resource_name_list << resource_name unless resource_name.nil? or resource_name.strip.empty?
        end

        if resource_name_list.count > 0
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

          # FOPS-487
          link_descr = "View resource"
          #link_descr = manifest.fileset_link(resource_name_list.first)
          link_markup = manifest.fileset_link_markup(
                  resource_name_list.first,
                  {
                      description: link_descr,
                      #download: manifest.fileset_allow_download(resource_name_list.first)
                  }
                )
          last_block = block_list.last
          if last_block.nil?
            last_block = caption_node.document.create_element("p")
            link_container = last_block
            caption_node.add_child(last_block)
          else
            link_container = last_block.document.create_element("span")
            last_block.add_child(link_container)
          end
          link_container.add_class("default-media-display")
          if last_block.content.strip.end_with?('.')
            ll = " " + link_markup + "."
          else
            ll = ". " + link_markup + "."
          end
          link_container.add_child(ll)
          fragment_node.remove_class("enhanced-media-display")

=begin
          caption_field = reference_node["data-fulcrum-embed-caption-field"]
          caption_field = caption_field.strip.downcase unless caption_field.nil?
          caption_link = reference_node["data-fulcrum-embed-caption-link"]
          caption_link = (caption_link.strip.downcase == "true") unless caption_link.nil?
          cf = caption_field.nil? ? "caption" : caption_field
          cl = caption_link.nil? ? false : caption_link

          resource_name_list.each do |resource_name|
            if caption_added
              if caption_field.nil? and caption_link.nil?
                caption_node.add_child(CLASS_FORMAT_STR % ["default-media-display", resource_name, cf, "true"])
                caption_node.add_child(CLASS_FORMAT_STR % ["enhanced-media-display", resource_name, cf, cl])
              else
                caption_node.add_child(FORMAT_STR % [resource_name, cf, cl])
              end
            else
              disp_node_list = block_list.select {|n|
                !(n.classes().include?("default-media-display") \
                    or n.classes().include?("enhanced-media-display"))
              }
              disp_node_list.each {|n| n.add_class("enhanced-media-display") }

              def_node_list = block_list.select {|n| n.classes().include?("default-media-display") }
              if def_node_list.count == 0
                caption_node.add_child(CLASS_FORMAT_STR % ["default-media-display", resource_name, cf, "true"])
#=begin
                # FOPS-514
                if manifest.fileset_external_resource_url(resource_name).empty?
                  caption_node.add_child(CLASS_FORMAT_STR % ["default-media-display", resource_name, cf, "true"])
                else
                  caption_node.add_child(FORMAT_STR % [resource_name, cf, "true"])
                end
#=end
              end
#=begin
              disp_node_list = block_list.select {|n| n.classes().include?("default-media-display") }
              disp_node_list.each {|n| n.remove_class("default-media-display") }
              disp_node_list = block_list.select {|n| n.classes().include?("enhanced-media-display") }
              disp_node_list.each do |n|
                n.remove_class("enhanced-media-display")
                n["style"] = "display:none"
              end
#=end
            end
#=begin
            fs = manifest.fileset(resource_name)
            ext_resource_id = fs["external_resource_id"]
            fragment_node["data-fulcrum-embed-filename"] = ext_resource_id
#=end
            fragment_node.remove_attribute("style")
          end
=end
          caption_node.xpath(".//*[@*[starts-with(local-name(),'data-fulcrum-')]]").each do |node|
            insert_metadata(node, resource_name_list.first)
          end
          action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                   name: name,
                   reference_node: reference_node,
                   action: :replace_node,
                   markup: fragment_node.to_xml,
                   info_message: "#{reference_node.name}: links for resources #{resource_name_list.join(',')}"
               )
        else
          res_node_list = fragment_node.xpath("./*[@data-fulcrum-embed-filename]")
          if res_node_list.count > 1
            res_name_list = res_node_list.collect {|n| n['data-fulcrum-embed-filename'] }
            action_list << UMPTG::XML::Pipeline::Action.new(
                     name: name,
                     reference_node: reference_node,
                     warning_message: "#{caption_node.name}: multiple caption resource references found #{res_name_list.join(',')}"
                 )
          elsif res_node_list.count == 1
            res_node = res_node_list.first
            embed_filename = res_node['data-fulcrum-embed-filename']
            fragment_node['data-fulcrum-embed-filename'] = embed_filename

            res_node.remove_attribute('data-fulcrum-embed-filename')
            res_node.remove if res_node.content.strip.empty?

            unless caption_node.nil?
              caption_node.xpath(".//*[@*[starts-with(local-name(),'data-fulcrum-')]]").each do |node|
                insert_metadata(node, resource_name_list.first)
              end
            end

            action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                     name: name,
                     reference_node: reference_node,
                     action: :replace_node,
                     markup: fragment_node.to_xml,
                     info_message: "#{reference_node.name}: setting @data-fulcrum-embed-filename=\"#{embed_filename}\"."
                 )
          end
        end
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

    def create_img_actions(reference_node)
      reference_name = reference_node["src"]

      action_list = []

      content = manifest.fileset_title(reference_name)
      unless content.empty?
        link_markup = manifest.fileset_link_markup(
                reference_name,
                {
                    description: content,
                    #download: manifest.fileset_allow_download(reference_name)
                }
              )
        markup = "<span class=\"default-media-display\">" + link_markup + "</span>"

        action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                 name: name,
                 reference_node: reference_node,
                 action: :add_next,
                 markup: markup,
                 info_message: "#{reference_name}: links for resource"
             )
      end
      return action_list
    end

    def insert_metadata(node, rn = nil)
      resource_name = node["data-fulcrum-embed-filename"] || rn
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

      if link == "true"
        markup = manifest.fileset_link_markup(
                resource_name,
                {
                    description: content,
                    #download: manifest.fileset_allow_download(resource_name)
                }
              )
      else
        markup = content
      end

      node.remove_attribute("data-fulcrum-embed-filename") \
          unless node.classes().include?("enhanced-media-display")
      node.remove_attribute("data-fulcrum-embed-caption-field")
      node.remove_attribute("data-fulcrum-embed-caption-link")

      case node.name
      when "span"
        n = node.replace(Nokogiri::XML::DocumentFragment.parse(markup)) \
                unless node.parent.nil?
        n = Nokogiri::XML::DocumentFragment.parse(markup) \
                if node.parent.nil?
        return n
      else
        node.add_child(markup)
      end
      return node
    end
  end
end
