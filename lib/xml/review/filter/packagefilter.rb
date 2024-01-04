module UMPTG::XML::Review::Filter

  class PackageFilter < UMPTG::XML::Pipeline::Filter

    PACKAGE_XPATH = <<-PCKXPATH
    //*[
    local-name()='metadata'
    ]/*[
    %s
    ]
    PCKXPATH

    ACCESSMODEVISUAL_XPATH = <<-AMVXPATH
    ./*[
    local-name()='meta'
    and @property='schema:accessMode'
    and string()='visual'
    ]
    AMVXPATH

    ACCESSSTRUCTNAV_XPATH = <<-ASNXPATH
    ./*[
    local-name()='meta'
    and @property='schema:accessibilityFeature'
    and string()='structuralNavigation'
    ]
    ASNXPATH

    ACCESSDISPTRANSFORM_XPATH = <<-ADTXPATH
    ./*[
    local-name()='meta'
    and @property='schema:accessibilityFeature'
    and string()='displayTransformability'
    ]
    ADTXPATH

    ACCESSREADINGORDER_XPATH = <<-AROXPATH
    ./*[
    local-name()='meta'
    and @property='schema:accessibilityFeature'
    and string()='readingOrder'
    ]
    AROXPATH

    LINKCONFORMS_XPATH = <<-LCXPATH
    .//*[
    local-name()='link'
    and @rel='dcterms:conformsTo'
    and starts-with(@href,' ')
    ]
    LCXPATH

    COVERITEM_XPATH = <<-CIXPATH
    //*[
    local-name()='manifest'
    ]/*[
    local-name()='item' and contains(concat(' ',@properties,' '),'cover-image')
    ]
    CIXPATH

    COVERMETA_XPATH = <<-CMXPATH
    ./*[
    local-name()='meta' and @name='cover'
    ]
    CMXPATH

    COVERID_XPATH = <<-CDXPATH
    //*[
    local-name()='manifest'
    ]/*[
    local-name()='item' and @id='%s'
    ]
    CDXPATH

    def initialize(args = {})
      args[:name] = :package

      @child_elements = [ 'dc:title', 'dc:creator', 'dc:language', 'dc:rights', 'dc:publisher', 'dc:identifier' , 'dc:source' ]
      xpath = sprintf(PACKAGE_XPATH, @child_elements.collect {|x| "name()='#{x}'"}.join(' or '))
      args[:selector] = UMPTG::XML::Review::ElementSelector.new(
              selection_xpath: xpath
            )
      super(args)
    end

    def run(xml_doc, args = {})
      act = super(xml_doc, args)

      metadata_node = xml_doc.xpath("//*[local-name()='metadata']").first
      return act if metadata_node.nil?

      actions = []
      @child_elements.each do |elem|
        alist = act.select do |a|
          element_name = a.reference_node.namespace.prefix ?
              "#{a.reference_node.namespace.prefix}:#{a.reference_node.name}" : a.reference_node.name
          element_name == elem
        end
        if alist.empty?
          new_act = UMPTG::XML::Pipeline::Action.new(reference_node: metadata_node)
          new_act.add_warning_msg("#{metadata_node.name} #1: element #{elem} not found.")
        else
          new_act = UMPTG::XML::Pipeline::Action.new(reference_node: alist.first)
          new_act.add_info_msg("#{metadata_node.name} #1: element #{elem} found.")
        end
        actions << new_act
      end

      # Remove duplicate <meta property="schema:accessMode">visual</meta>.
      actions += remove_duplicates(
                @name,
                metadata_node,
                ACCESSMODEVISUAL_XPATH,
                msgs = {
                      present: "Metadata: meta/@schema:accessMode='visual' is present.",
                      not_present: "Metadata: meta/@schema:accessMode='visual' is not present.",
                      remove: "Metadata: extra meta/@schema:accessMode='visual' should be removed."
                  },
                "<meta property=\"schema:accessMode\">visual</meta>"
             )

      # Remove duplicate <meta property="schema:accessibilityFeature">structuralNavigation</meta>.
      actions += remove_duplicates(
                @name,
                metadata_node,
                ACCESSSTRUCTNAV_XPATH,
                msgs = {
                      present: "Metadata: meta/@schema:accessibilityFeature='structuralNavigation' is present.",
                      not_present: "Metadata: meta/@schema:accessibilityFeature='structuralNavigation' is not present.",
                      remove: "Metadata: extra meta/@schema:accessibilityFeature='structuralNavigation' should be removed."
                  }
             )

      # Remove duplicate <meta property="schema:accessibilityFeature">displayTransformability</meta>.
      actions += remove_duplicates(
                @name,
                metadata_node,
                ACCESSDISPTRANSFORM_XPATH,
                msgs = {
                      present: "Metadata: meta/@schema:accessibilityFeature='displayTransformability' is present.",
                      not_present: "Metadata: meta/@schema:accessibilityFeature='displayTransformability' is not present.",
                      remove: "Metadata: extra meta/@schema:accessibilityFeature='displayTransformability' should be removed."
                  },
                "<meta property=\"schema:accessibilityFeature\">displayTransformability</meta>"
             )

      # Remove duplicate <meta property="schema:accessibilityFeature">readingOrder</meta>.
      actions += remove_duplicates(
                @name,
                metadata_node,
                ACCESSREADINGORDER_XPATH,
                msgs = {
                      present: "Metadata: meta/@schema:accessibilityFeature='readingOrder' is present.",
                      not_present: "Metadata: meta/@schema:accessibilityFeature='readingOrder' is not present.",
                      remove: "Metadata: extra meta/@schema:accessibilityFeature='readingOrder' should be removed."
                  }
             )

      # Remove any leading spaces in <link rel="dcterms:conformsTo" href=" http://www.idpf.org/epub/a11y/accessibility-20170105.html#wcag-aa"/>.
      node_list = metadata_node.xpath(LINKCONFORMS_XPATH)
      if node_list.empty?
        actions << UMPTG::XML::Pipeline::Action.new(
               name: @name,
               reference_node: metadata_node,
               info_message: "Metadata: link/@dcterms:conformsTo has @href value without leading spaces."
           )
      else
        node_list.each_with_index do |node,ndx|
          actions << UMPTG::XML::Pipeline::Actions::StripAttributeValueAction.new(
                 name: @name,
                 reference_node: node,
                 attribute_name: "href",
                 warning_message: "Metadata: link/@dcterms:conformsTo has @href value with leading spaces."
             )
        end
      end

      node_list = xml_doc.xpath(COVERITEM_XPATH)
      if node_list.empty?
        # No cover item. See if the metadata indicates the cover item.
        node_list = metadata_node.xpath(COVERMETA_XPATH)
        unless node_list.empty?
          # Get cover id.
          cover_id = node_list.first['content']
          node_list = xml_doc.xpath(sprintf(COVERID_XPATH,cover_id))
          unless node_list.empty?
            # Found the cover item. Add the 'cover-image' prooperty.
            actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: @name,
                    reference_node: node_list.first,
                    attribute_name: 'properties',
                    attribute_value: 'cover-image',
                    attribute_append: true
                  )
          end
        end
      end
      return actions
    end

    private

    def remove_duplicates(name, context_node, xpath, msgs, markup = "")
      actions = []

      node_list = context_node.xpath(xpath)
      if node_list.empty?
        reference_node = context_node.xpath("./*[local-name()='meta' and starts-with(@property,'schema:access')]")
        reference_node = context_node.xpath("./*[local-name()='meta'][last()]") if reference_node.empty?
        reference_node = context_node.xpath("./*[last()]") if reference_node.empty?
        actions << UMPTG::XML::Pipeline::Actions::NormalizeInsertMarkupAction.new(
               name: name,
               reference_node: reference_node.first,
               warning_message: msgs[:not_present],
               markup: markup
           )
      else
        node_list.each_with_index do |node,ndx|
          case ndx
          when 0
            actions << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: node,
                   info_message: msgs[:present]
               )
          else
            actions << UMPTG::XML::Pipeline::Actions::RemoveElementAction.new(
                      name: name,
                      reference_node: node,
                      action_node: node,
                      warning_message: msgs[:remove]
                    )
          end
        end
      end
      return actions
    end
  end
end
