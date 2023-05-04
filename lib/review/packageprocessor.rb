module UMPTG::Review
  class PackageProcessor < ElementEntryProcessor
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
      args[:container_elements] = [ 'metadata' ]
      args[:child_elements] = [ 'dc:title', 'dc:creator', 'dc:language', 'dc:rights', 'dc:publisher', 'dc:identifier' , 'dc:source' ]
      super(args)
    end

    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      action_list = super(args)

      metadata_list = xml_doc.xpath("//*[local-name()='metadata']")
      unless metadata_list.empty?
        if metadata_list.count > 1
          # Shouldn't happen
          action_list << Action.new(
                 name: name,
                 reference_node: metadata_list.first,
                 warning_message: "Metadata: multiple metadata elements found, first being reviewed."
             )
        end

        # Remove duplicate <meta property="schema:accessMode">visual</meta>.
        action_list += remove_duplicates(
                  name,
                  metadata_list.first,
                  ACCESSMODEVISUAL_XPATH,
                  msgs = {
                        present: "Metadata: meta/@schema:accessMode='visual' is present.",
                        not_present: "Metadata: meta/@schema:accessMode='visual' is not present.",
                        remove: "Metadata: extra meta/@schema:accessMode='visual' should be removed."
                    }
               )

        # Remove duplicate <meta property="schema:accessibilityFeature">structuralNavigation</meta>.
        action_list += remove_duplicates(
                  name,
                  metadata_list.first,
                  ACCESSSTRUCTNAV_XPATH,
                  msgs = {
                        present: "Metadata: meta/@schema:accessibilityFeature='structuralNavigation' is present.",
                        not_present: "Metadata: meta/@schema:accessibilityFeature='structuralNavigation' is not present.",
                        remove: "Metadata: extra meta/@schema:accessibilityFeature='structuralNavigation' should be removed."
                    }
               )

        # Remove duplicate <meta property="schema:accessibilityFeature">displayTransformability</meta>.
        action_list += remove_duplicates(
                  name,
                  metadata_list.first,
                  ACCESSDISPTRANSFORM_XPATH,
                  msgs = {
                        present: "Metadata: meta/@schema:accessibilityFeature='displayTransformability' is present.",
                        not_present: "Metadata: meta/@schema:accessibilityFeature='displayTransformability' is not present.",
                        remove: "Metadata: extra meta/@schema:accessibilityFeature='displayTransformability' should be removed."
                    }
               )

        # Remove duplicate <meta property="schema:accessibilityFeature">readingOrder</meta>.
        action_list += remove_duplicates(
                  name,
                  metadata_list.first,
                  ACCESSREADINGORDER_XPATH,
                  msgs = {
                        present: "Metadata: meta/@schema:accessibilityFeature='readingOrder' is present.",
                        not_present: "Metadata: meta/@schema:accessibilityFeature='readingOrder' is not present.",
                        remove: "Metadata: extra meta/@schema:accessibilityFeature='readingOrder' should be removed."
                    }
               )

        # Remove any leading spaces in <link rel="dcterms:conformsTo" href=" http://www.idpf.org/epub/a11y/accessibility-20170105.html#wcag-aa"/>.
        node_list = metadata_list.first.xpath(LINKCONFORMS_XPATH)
        if node_list.empty?
          action_list << Action.new(
                 name: name,
                 reference_node: metadata_list.first,
                 info_message: "Metadata: link/@dcterms:conformsTo has @href value without leading spaces."
             )
        else
          node_list.each_with_index do |node,ndx|
            action_list << StripAttributeValueAction.new(
                   name: name,
                   reference_node: node,
                   attribute_name: "href",
                   warning_message: "Metadata: link/@dcterms:conformsTo has @href value with leading spaces."
               )
          end
        end
      end
      node_list = xml_doc.xpath(COVERITEM_XPATH)
      if node_list.empty?
        # No cover item. See if the metadata indicates the cover item.
        node_list = metadata_list.first.xpath(COVERMETA_XPATH)
        unless node_list.empty?
          # Get cover id.
          cover_id = node_list.first['content']
          node_list = xml_doc.xpath(sprintf(COVERID_XPATH,cover_id))
          unless node_list.empty?
            # Found the cover item. Add the 'cover-image' prooperty.
            action_list << SetAttributeValueAction.new(
                    name: name,
                    reference_node: node_list.first,
                    attribute_name: 'properties',
                    attribute_value: 'cover-image',
                    attribute_append: true
                  )
          end
        end
      end
      return action_list
    end

    private

    def remove_duplicates(name, context_node, xpath, msgs)
      action_list = []

      node_list = context_node.xpath(xpath)
      if node_list.empty?
        action_list << Action.new(
               name: name,
               reference_node: context_node,
               warning_message: msgs[:not_present]
           )
      else
        node_list.each_with_index do |node,ndx|
          case ndx
          when 0
            action_list << Action.new(
                   name: name,
                   reference_node: node,
                   info_message: msgs[:present]
               )
          else
            action_list << RemoveElementAction.new(
                      name: name,
                      reference_node: node,
                      action_node: node,
                      warning_message: msgs[:remove]
                    )
          end
        end
      end
      return action_list
    end
  end
end
