module UMPTG::EPUB::Migrator::Filter

  class XHTMLFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name()='head'
    ] | //*[
    local-name()='img'
    ] | //*[
    local-name()='svg'
    ] | //*[
    local-name()='table'
    ] | //*[
    @href
    ]
    PCKXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      reference_node = args[:reference_node]

      actions = []

      case reference_node.name
      when "head"
        actions += process_heading(reference_node, args)
      when "img"
        actions += process_img(reference_node, args)
      when "svg"
        actions += process_svg(reference_node, args)
      when "table"
        actions += process_table(reference_node, args)
      else
        if reference_node.has_attribute?("href")
          actions += process_href(reference_node, args)
        else
          actions << UMPTG::XML::Pipeline::Action.new(
                          name: name,
                          reference_node: reference_node,
                          info_message: "#{name}, #{reference_node.name}"
                      )
        end
      end
      return actions
    end

    private

    def process_heading(reference_node, args)
      actions = []

      content = "text/html; charset=utf-8"
      markup = "<meta http-equiv=\"Content-Type\" content=\"#{content}\"/>"

      ctype_list = reference_node.xpath(".//*[local-name()='meta' and @http-equiv='Content-Type']")
      if ctype_list.empty?
        actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  name: name,
                  reference_node: reference_node,
                  action: :add_child,
                  markup: markup,
                  warning_message: "#{name}, missing meta[@http-equiv='Content-Type']/@content=\"#{content}\""
                )
      else
        ctype_list.each do |n|
          actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: name,
                    reference_node: n,
                    attribute_name: "content",
                    attribute_value: content,
                    warning_message: "#{name}, invalid meta[@http-equiv='Content-Type']/@content=\"#{n['content']}\""
                  )
        end
      end
      return actions
    end

    def process_img(reference_node, args)
      actions = []

      ["height","width"].each do |attr|
        v = reference_node[attr]
        unless v.nil?
          actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                    name: name,
                    reference_node: reference_node,
                    attribute_name: attr,
                    warning_message: "#{name}, invalid attribute #{reference_node.name}/@#{attr}"
                  )
        end
      end

      width = reference_node["width"]
      width = width.nil? ? "" : width.strip
      if width == "100%"
        actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: "width",
                  warning_message: "#{name}, invalid attribute #{reference_node.name}/@width"
                )
      end
      return actions
    end

    def process_svg(reference_node, args)
      actions = []

      div_node = reference_node.document.create_element("div")
      reference_node.xpath(".//*[local-name()='image']").each do |svg_img|
        img_node = reference_node.document.create_element("img")
        div_node.add_child(img_node)
        svg_img.attributes.each do |a,v|
          case a
          when "href"
            img_node["src"] = v
          when "width", "height"
            img_node[a] = v
          end
        end
      end

      actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                name: name,
                reference_node: reference_node,
                action: :replace_node,
                markup: div_node.to_xml,
                warning_message: "#{name}, found #{reference_node.name}"
              )

      return actions
    end

    def process_table(reference_node, args)
      actions = []

      # Remove @[cellspacing|width]
      ["cellspacing","width"].each do |attr|
        v = reference_node[attr]
        unless v.nil?
          actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                    name: name,
                    reference_node: reference_node,
                    attribute_name: attr,
                    warning_message: "#{name}, invalid attribute #{reference_node.name}/@#{attr}"
                  )
        end
      end

      # Remove @border="0"
      attr = "border"
      attr_value = reference_node[attr]
      unless attr_value.nil? or !attr_value.strip.match?(/[0]+/)
        actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: attr,
                  warning_message: "#{name}, invalid attribute #{reference_node.name}/@#{attr}"
                )
      end

      # Move @cellpadding to @style
      attr = "cellpadding"
      attr_value = reference_node[attr]
      unless attr_value.nil?
        actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: "style",
                  attribute_value: "padding:#{attr_value.strip}",
                  attribute_append: true,
                  warning_message: "#{name}, invalid #{reference_node.name}/@#{attr}"
                )
        actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: attr,
                  warning_message: "#{name}, invalid attribute #{reference_node.name}/@#{attr}"
                )
      end

      # Move @align and @valign to @style
      attr_list = reference_node.xpath(".//@*[name()='align' or name()='valign']")
      attr_list.each do |attr|
        unless attr.content.strip.empty?
          val = attr.name == "valign" ? "text-align" : attr.name
          val += ":#{attr.content}"
          actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: name,
                    reference_node: attr.parent,
                    attribute_name: "style",
                    attribute_value: val,
                    attribute_append: true,
                    warning_message: "#{name}, invalid #{attr.parent.name}/@#{attr.name}"
                  )
          actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                    name: name,
                    reference_node: attr.parent,
                    attribute_name: attr.name,
                    warning_message: "#{name}, invalid attribute #{reference_node.name}/@#{attr.name}"
                  )
        end
      end

      # Remove col/@[height|width]
      col_node_list = reference_node.xpath(".//*[local-name()='col' and (@height or @width)]")
      col_node_list.each do |col_node|
        ["height","width"].each do |attr|
          v = col_node[attr]
          unless v.nil?
            actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                      name: name,
                      reference_node: col_node,
                      attribute_name: attr,
                      warning_message: "#{name}, invalid attribute #{col_node.name}/@#{attr}"
                    )
          end
        end
      end

      # Confirm that the tbody element exists
      tbody_node = reference_node.xpath(".//*[local-name()='tbody']").first
      if tbody_node.nil?
        actions << UMPTG::XML::Pipeline::Actions::TableMarkupAction.new(
                  name: name,
                  reference_node: reference_node,
                  action: :add_tbody,
                  warning_message: "#{name}, missing #{reference_node.name}/tbody"
                )
      end

      return actions
    end

    def process_href(reference_node, args)
      actions = []

      href = reference_node['href']
      new_href = UMPTG::EPUB::Migrator.fix_ext(href)
      unless href == new_href
        actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: "href",
                  attribute_value: new_href,
                  warning_message: "#{name}, found #{reference_node.name}/@href=\"#{href}\""
                )
      end

      return actions
    end
  end
end
