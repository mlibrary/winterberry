module UMPTG::Resources

  class ResourceProcessor
    def initialize(args = {})
      @resource_map = args[:resource_map]
      @resource_metadata = args[:resource_metadata]
      @default_action_str = args[:default_action_str]
      @reference_processor = args[:reference_processor]
      @reference_action_defs = nil
    end

    def process(doc)
      init_reference_action_defs

      reference_action_list = @reference_processor.reference_actions(
                                  :xml_doc => doc,
                                  :reference_action_defs => @reference_action_defs
                                )
      reference_action_list.each do |reference_action|
        reference_action.process
        puts reference_action
        puts reference_action.message \
            unless reference_action.message.nil? or reference_action.message.empty?
      end

      return reference_action_list
    end

    private

    def init_reference_action_defs
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
                      :resource_map_action => map_action,
                      :resource_metadata => fileset_row
                    )

          def_list << reference_action_def
          reference_action_def_map[reference_name] = def_list
          #reference_action_def_list << reference_action_def
        end
        @reference_action_defs = reference_action_def_map
      end
    end
  end
end
