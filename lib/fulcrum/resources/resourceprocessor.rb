module UMPTG::Fulcrum::Resources

  # Class processes each resource reference found within XML content.
  class ResourceProcessor < UMPTG::EPUB::EntryProcessor

    # Processing parameters:
    #   :default_action         Default resource action, embed|link|none
    #   :resource_metadata      Monograph resource metadata
    #   :resource_map           Resource reference to fileset mapping
    #   :logger                 Log messages
    def initialize(args = {})
      super(args)

      @default_action = @properties[:default_action]
      @resource_metadata = @properties[:resource_metadata]
      @resource_map = @properties[:resource_map]
      @logger = @properties[:logger]

      @reference_action_defs = nil
    end

    def actions(args = {})
      epub = args[:epub]
      type = args[:type]

      init_reference_action_defs()

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
=begin
    def element_reference_actions(args = {})
      name = args[:name]
      node = args[:reference_container]

      reference_action_list = []

      reference_src = node['src']

      unless reference_src.nil? or reference_src.strip.empty?
        reference_src.strip!

        # Select references within container
        node_list = node.xpath("./ancestor::*[local-name()='figure' or (local-name()='p' and @class='fig')][1]")
        if node_list.empty?
            @logger.warn("No container found for reference #{reference_src}.")
        else
          reference_container = node_list.first

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
      end
      return reference_action_list
    end
    def element_reference_actions(args = {})
      name = args[:name]
      reference_container = args[:reference_container]

      # Select references within container
      node_list = reference_container.xpath(".//*[local-name()='img']")

      # For each reference, create an action.
      reference_action_list = []
      node_list.each do |node|
        # Determine the resource name from the reference node
        src_attr = node.attribute("src")
        next if src_attr.nil?

        # Determine the assigned action for this reference
        spath = src_attr.value.strip
        reference_action_def_list = @reference_action_defs[spath]
        if reference_action_def_list.nil?
          @logger.warn("Reference #{spath} has no action definition.")
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
      return reference_action_list
    end
=end

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

    def init_reference_action_defs()
      if @reference_action_defs.nil?

        # Generate the resource action map,
        # resource reference => resource metadata.
        reference_action_def_map = {}
        map_actions = @resource_map.actions
        map_actions.each do |map_action|
          reference_name = map_action.reference.name
          resource_name = map_action.resource.name
          if resource_name == nil or resource_name.strip.empty?
            @logger.warn("No resource  mapping found for reference #{File.basename(reference_name)}")
            next
          end

          # Determine if this reference/resource pair has already
          # been defined. If so, use the first instance and skip
          # this one.
          def_list = reference_action_def_map[reference_name]
          def_list = [] if def_list.nil?
          unless def_list.empty?
            dlist = def_list.find {|d|
              d.reference_name == reference_name and d.resource_name == resource_name
            }
            unless dlist.nil?
              @logger.warn("Multiple action definitions #{reference_name}/#{resource_name}. Using first instance.")
              next
            end
          end

          # Use resource name to find manifest row. If there is no
          # NOID specified, then this is an invalid row.
          fileset_row = @resource_metadata.fileset(resource_name)
          if fileset_row['noid'].empty?
            @logger.error("No fileset row for resource #{resource_name}")
          else
            @logger.info("Reference #{File.basename(reference_name)} mapped to resource #{resource_name}")
          end

          map_action.type = @resource_map.default_action if map_action.type == :default
          reference_action_def = ReferenceActionDef.new(
                      resource_map_action: map_action,
                      resource_metadata: fileset_row
                    )

          def_list << reference_action_def
          reference_action_def_map[reference_name] = def_list
        end
        @reference_action_defs = reference_action_def_map
      end
    end
  end
end
