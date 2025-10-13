module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class OPFFilter < UMPTG::XML::Pipeline::Filter

    PACKAGE_XPATH = <<-PCKXPATH
    //*[
    local-name() = 'package'
    ] | //*[
    local-name()='metadata'
    ] | //*[
    local-name()='manifest' or local-name()='guide'
    ] | //*[
    local-name()='spine'
    ]
    PCKXPATH

    OPF_REMOVEATTR_XPATH = <<-ORX
    .//@*[
    namespace-uri()='http://www.idpf.org/2007/opf'
    and (
    local-name()='scheme'
    or local-name()='event'
    or local-name()='role'
    or local-name()='file-as'
    )
    ]
    ORX

    def initialize(args = {})
      a = args.clone
      a[:name] = :epub_oebps_opf
      a[:xpath] = PACKAGE_XPATH
      super(a)
    end

    def create_actions(args = {})
      reference_node = args[:reference_node]

      actions = []

      case reference_node.name
      when "package"
        actions += process_package(reference_node, args)
      when "metadata"
        actions += process_metadata(reference_node, args)
      #when "manifest", "guide"
      when "guide"
        actions += process_manifest(reference_node, args)
      when "spine"
        actions += process_spine(reference_node, args)
      else
      end

      return actions
    end

    private

    def process_package(reference_node, args)
      actions = []

      direction = reference_node["dir"]
      direction = direction.nil? ? "" : direction
      if direction.empty?
=begin
        actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: "dir",
                  attribute_value: "ltr",
                  warning_message: "#{name}, no value for #{reference_node.name}/@dir"
                )
=end
      else
        actions << UMPTG::XML::Pipeline::Action.new(
                  name: name,
                  reference_node: reference_node,
                  info_message: "#{name}, found value for #{reference_node}/@dir"
                )
      end

      version = reference_node["version"]
      case version.strip[0]
      when "3"
        actions << UMPTG::XML::Pipeline::Action.new(
                        name: name,
                        reference_node: reference_node,
                        info_message: "#{name}, version=#{version}"
                    )
      else
        actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: "version",
                  attribute_value: "3.0",
                  warning_message: "#{name}, version=#{version}"
                )
      end

      return actions
    end

    def process_metadata(reference_node, args)
      actions = []

      # Set[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z
      tm = Time.now
      mdate = tm.strftime("%Y-%m-%dT%H:%M:%SZ")

      mdate_list = reference_node.xpath("./*[local-name()='meta' and @property='dcterms:modified']")
      if mdate_list.empty?
        dte_actions = []

        # If found, transform dc:date/@opf:event="modification" to meta/@property="dcterms:modified"
        markup = "<meta property=\"dcterms:modified\">#{mdate}</>"

        opf_dates = reference_node.xpath(".//@*[namespace-uri()='http://www.idpf.org/2007/opf' and local-name()='event']")
        opf_dates.each do |d|
          if d.content.downcase.start_with?("modif")
            dte_actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                      name: name,
                      reference_node: d.parent,
                      action: :replace_node,
                      markup: markup,
                      warning_msg: "#{name} invalid #{d.parent.name}/@opf:#{d.name}=\"#{d.content}\""
                    )
          end
        end
        if dte_actions.empty?
          dte_actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    name: name,
                    reference_node: reference_node,
                    action: :add_child,
                    markup: markup,
                    warning_msg: "#{name}, missing metadata/meta[@property='dcterms:modified']"
                  )
        end
        actions += dte_actions
      else
        mdate_list.each do |n|
          actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    name: name,
                    reference_node: n,
                    action: :replace_content,
                    markup: mdate,
                    warning_message: "#{name}, invalid metadata/meta[@property='dcterms:modified'] content"
                  )
        end
      end

      alist = reference_node.xpath(OPF_REMOVEATTR_XPATH)
      alist.each do |n|
        actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                  name: name,
                  reference_node: n.parent,
                  attribute_name: n.name,
                  warning_message: "#{name}, invalid attribute #{n.name}"
                )
      end
      return actions
    end

    def process_manifest(reference_node, args)
      actions = []
      href_list = reference_node.xpath("./*[local-name()='item' or local-name()='reference']")
      href_list.each do |n|
        href = n['href']
        new_href = UMPTG::XHTML::fix_ext(href)
        unless href == new_href
          actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: name,
                    reference_node: n,
                    attribute_name: "href",
                    attribute_value: new_href,
                    warning_message: "#{name}, found #{reference_node.name}/@href=\"#{href}\""
                  )
        end
      end
=begin
      ncx_item_node = reference_node.xpath("./*[local-name()='item' and @media-type='application/x-dtbncx+xml']").first
      unless ncx_item_node.nil?
        nav_item = reference_node.xpath("./*[local-name()='item' and contains(concat(' ', @properties, ' '), ' nav ')]").first
        if nav_item.nil?
          m = "<item id=\"toc_xhtml\" href=\"toc_nav.xhtml\" media-type=\"application/xhtml+xml\" properties=\"nav\"/>"
          actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    name: name,
                    reference_node: ncx_item_node,
                    action: :add_next,
                    markup: m,
                    warning_message: "#{name}, missing XML navigation"
                  )
        end
      end
=end
      return actions
    end

    def process_spine(reference_node, args)
      actions = []

      lin_list = reference_node.xpath("./*[local-name()='itemref' and @linear='no']")
      lin_list.each do |n|
        actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                  name: name,
                  reference_node: n,
                  attribute_name: "linear",
                  warning_message: "#{name}, found #{reference_node.name}/#{n.name}[@idref=\"#{n['idref']}\"]/@linear=\"no\""
                )
      end

      return actions
    end
  end
end
