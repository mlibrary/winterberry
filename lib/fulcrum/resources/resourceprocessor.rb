module UMPTG::Fulcrum::Resources

  # Class processes each resource reference found within XML content.
  class ResourceProcessor < UMPTG::EPUB::EntryProcessor

    # Processing parameters:
    #   :default_action         Default resource action, embed|link|none
    #   :resource_map           Resource reference to fileset mapping
    #   :resource_action_defs   Resource action map,breference => metadata.
    #   :logger                 Log messages
    def initialize(args = {})
      super(args)

      @default_action = @properties[:default_action]
      @resource_map = @properties[:resource_map]
      @reference_action_defs = @properties[:reference_action_defs]
      @logger = @properties[:logger]
    end

    def actions(args = {})
      epub = args[:epub]
      type = args[:type]

      #init_reference_action_defs()

      entry_doc_map = {}
      reference_action_list = []
      @resource_map.actions.each do |action|
        next if action.reference_selector.empty?

        name = action.reference_entry
        element_type = action.element_type.to_sym
        entry = epub.entry(action.reference_entry)
        unless entry_doc_map.key?(entry.name)
          entry_doc_map[entry.name] = UMPTG::XMLUtil.parse(xml_content: entry.content)
        end
        entry_doc = entry_doc_map[entry.name]

        reference_node = entry_doc.xpath(action.reference_selector).first
        if reference_node.nil?
          script_logger.error("Reference not found #{action.reference.name}")
          next
        end

        reference_action_def_list = @reference_action_defs[action.reference.name]
        if reference_action_def_list.nil?
          @logger.warn("Reference #{reference_src} has no action definition.")
        end

        reference_action_def = reference_action_def_list.first
        args = {
                  name: name,
                  reference_container: nil,
                  reference_node: reference_node,
                  reference_action_def: reference_action_def

              }
        case element_type
        when :element
          case action.type
          when :embed
            case reference_action_def.resource_type
            when 'interactive map'
              reference_action = EmbedMapAction.new(args)
            else
              reference_action = EmbedElementAction.new(args)
            end
          when :link
            reference_action = LinkElementAction.new(args)
          when :remove
            reference_action = RemoveElementAction.new(
                                reference_action_def: reference_action_def,
                                reference_container: reference_container,
                                reference_node: node
                              )
          when :none
            reference_action = NoneAction.new(args)
          when :update_alt
            reference_action = UpdateAltAction.new(args)
          when :append_map_caption
            reference_action = AppendMapCaptionAction.new(args)
          else
            @logger.warn("Invalid element type #{action.type}")
            reference_action.nil?
          end
        when :marker
          case action.type
          when :embed
            reference_action = EmbedMarkerAction.new(args)
          when :link
            reference_action = LinkMarkerAction.new(args)
          when :none
            reference_action = NoneAction.new(args)
          else
            @logger.warn("Invalid marker action #{action.type}")
            reference_action = nil
          end
        end
        reference_action_list << reference_action unless reference_action.nil?
      end

      # Process all the Actions for this XML content.
      reference_action_list.each do |action|
        action.process()
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end

    # Method generates and processes a list of actions
    # for the specified XML content.
    #
    # Parameters:
    #   :name         Identifier associated with XML content
    #   :xml_doc      XML content document.
    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      init_reference_action_defs()

      reference_action_list = []
      @resource_map.selectors.each do |type,expr|
        container_list = xml_doc.xpath(expr)

        case type
        when :element
          container_list.each do |container|
            reference_action_list += element_reference_actions(
                       name: name,
                       reference_container: container
                     )
          end
        when :marker
          container_list.each do |container|
            reference_action_list += marker_reference_actions(
                       name: name,
                       reference_container: container
                     )
          end
        end
      end

      # Process all the Actions for this XML content.
      reference_action_list.each do |action|
        action.process()
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end

    private

    # Method selects all resource references within a container.
    #
    # Parameters:
    #   :name                   XML content identifier
    #   :reference_container    XML element containing references
    def element_reference_actions(args = {})
      name = args[:name]
      node = args[:reference_container]

      reference_container = nil
      reference_action_list = []

      reference_src = node['src']
      unless reference_src.nil? or reference_src.strip.empty?
        reference_src.strip!

        # Determine the assigned action for this reference
        reference_action_def_list = @reference_action_defs[reference_src]
        if reference_action_def_list.nil?
          @logger.warn("Reference #{reference_src} has no action definition.")
        else
          # Create the Action for this reference
          args = {
                    name: name,
                    reference_container: reference_container,
                    reference_node: node
                }
          reference_action_def_list.each do |reference_action_def|
            args[:reference_action_def] = reference_action_def

            case reference_action_def.action_str
            when :embed
              case reference_action_def.resource_type
              when 'interactive map'
                reference_action = EmbedMapAction.new(args)
              else
                reference_action = EmbedElementAction.new(args)
              end
            when :link
              reference_action = LinkElementAction.new(args)
            when :remove
              reference_action = RemoveElementAction.new(
                                  reference_action_def: reference_action_def,
                                  reference_container: reference_container,
                                  reference_node: node
                                )
            when :none
              reference_action = NoneAction.new(args)
            when :update_alt
              reference_action = UpdateAltAction.new(args)
            else
              @logger.warn("Invalid element action #{reference_action_def.action_str}")
              next
            end
            reference_action_list << reference_action
          end
        end
      end
      return reference_action_list
    end

    # Method selects all additional resource references within a container.
    #
    # Parameters:
    #   :name                   XML content identifier
    #   :reference_container    XML element containing references
    def marker_reference_actions(args = {})
      name = args[:name]
      reference_container = args[:reference_container]

      # Return the nodes that reference resources.
      # For marker callouts, this should be within
      # a XML comment, but not always the case.
      # NOTE: either display warning if no comment,
      # or just use the node content?
      node_list = reference_container.xpath(".//comment()")
      node_list = [ reference_container ] if node_list.nil? or node_list.empty?
      reference_action_list = []
      node_list.each do |node|
        path = node.text.strip

        #path = path.match(/insert[ ]+([^\>]+)/)[1]
        # Generally, additional resource references are expected
        # to use the markup:
        #     <p class="rb|rbi"><!-- resource_file_name.ext --></p>
        # But recently, Newgen has been using the markup
        #     <!-- <insert resource_file_name.ext> -->
        # So here we check for this case.
        r = path.match(/\<insert[ ]+([^\>]+)\>/)
        unless r.nil?
          # Appears to be Newgen markup.
          path = r[1]
        end

        # Determine the assigned action for this reference
        reference_action_def_list = @reference_action_defs[path]
        if reference_action_def_list.nil?
          @logger.warn("Marker #{path} has no action definition.")
          next
        end

        # Create the Action for this reference
        args = {
                  name: name,
                  reference_container: reference_container,
                  reference_node: node
              }
        reference_action_def_list.each do |reference_action_def|
          args[:reference_action_def] = reference_action_def

          case reference_action_def.action_str
          when :embed
            reference_action = EmbedMarkerAction.new(args)
          when :link
            reference_action = LinkMarkerAction.new(args)
          when :none
            reference_action = NoneAction.new(args)
          else
            @logger.warn("Invalid marker action #{reference_action_def.action_str}")
            reference_action = nil
          end

          reference_action_list << reference_action unless reference_action.nil?
        end
      end
      return reference_action_list
    end
  end
end
