module UMPTG::Resources

  class ResourceProcessor < UMPTG::EPUB::EntryProcessor
    def initialize(args = {})
      super(args)
      @resource_map = @properties[:resource_map]
      @resource_metadata = @properties[:resource_metadata]
      @default_action_str = @properties[:default_action_str]
      @reference_processor = @properties[:reference_processor]
      @reference_action_defs = nil

      @selector = @properties[:selector]
    end
    
    def action_list(args = {})
      name = args[:name]
      content = args[:content]

      alist = []
      begin
        doc = Nokogiri::XML(content, nil, 'UTF-8')
      rescue Exception => e
        puts e.message
        return alist
      end

      init_reference_action_defs()

      reference_container_list = @selector.references(doc)

      reference_action_list = []
      reference_container_list.each do |refnode|
        case @selector.reference_type(refnode)
        when :element
          list = element_reference_actions(
                      name: name,
                      reference_container: refnode
                    )
        when :marker
          list = marker_reference_actions(
                      name: name,
                      reference_container: refnode
                    )
        else
          next
        end
        reference_action_list += list
      end

      reference_action_list.each do |action|
        action.process()
      end
      return reference_action_list
    end

    private

    def element_reference_actions(args = {})
      name = args[:name]
      reference_container = args[:reference_container]

      node_list = reference_container.xpath(".//*[local-name()='img']")

      reference_action_list = []
      node_list.each do |node|
        src_attr = node.attribute("src")
        next if src_attr.nil?

        spath = src_attr.value.strip
        reference_action_def_list = @reference_action_defs[spath]
        if reference_action_def_list.nil?
          puts "Warning: reference #{spath} has no action definition."
          next
        end

        args = {
                  name: name,
                  reference_container: reference_container,
                  reference_node: node
              }

        reference_action_def_list.each do |reference_action_def|
          args[:reference_action_def] = reference_action_def

          case reference_action_def.action_str
          when "embed"
            case reference_action_def.resource_type
            when 'interactive map'
              reference_action = EmbedMapAction.new(args)
            else
              reference_action = EmbedElementAction.new(args)
            end
          when "link"
            reference_action = LinkElementAction.new(args)
          when "remove"
            reference_action = RemoveElementAction.new(
                                reference_action_def: reference_action_def,
                                reference_container: reference_container,
                                reference_node: node
                              )
          when "none"
            reference_action = NoneAction.new(args)
          else
            puts "Warning: invalid element action #{reference_action.to_s}"
            next
          end
          reference_action_list << reference_action
        end
      end
      return reference_action_list
    end

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

        reference_action_def_list = @reference_action_defs[path]
        if reference_action_def_list.nil?
          puts "Warning: marker #{path} has no action definition."
          next
        end

        args = {
                  name: name,
                  reference_container: reference_container,
                  reference_node: node
              }
        reference_action_def_list.each do |reference_action_def|
          args[:reference_action_def] = reference_action_def

          case reference_action_def.action_str
          when "embed"
            reference_action = EmbedMarkerAction.new(args)
          when "link"
            reference_action = LinkMarkerAction.new(args)
          when "none"
            reference_action = NoneAction.new(args)
          else
            puts "Warning: invalid marker action #{reference_action_def.action_str}"
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
            puts "Warning: no resource  mapping found for reference #{File.basename(reference_name)}"
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
              puts "Warning: multiple action definitions #{reference_name}/#{resource_name}. Using first instance."
              next
            end
          end

          # Use resource name to find manifest row. If there is no
          # NOID specified, then this is an invalid row.
          fileset_row = @resource_metadata.fileset(resource_name)
          if fileset_row['noid'].empty?
            puts "Error: no fileset row for resource #{resource_name}"
          else
            puts "Reference #{File.basename(reference_name)} mapped to resource #{resource_name}"
          end

          map_action.type = @default_action_str if map_action.type == "default"
          reference_action_def = UMPTG::Resources::ReferenceActionDef.new(
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
