module UMPTG::Fulcrum

  # Class defines the Action for a specific resource reference.
  # It contains the type of action (embed|link) and the Fulcrum
  # metadata for the resource.
  class ReferenceActions < UMPTG::Object
    attr_reader :resource_metadata

    def initialize(args = {})
      super(args)

      @resource_map = @properties[:resource_map]
      @resource_metadata = @properties[:resource_metadata]
      @logger = @properties[:logger]
      @reference_action_defs = nil
    end

    def def_list(resource_path)
      if @reference_action_defs.nil?

        # Generate the resource action map,
        # resource reference => resource metadata.
        reference_action_def_map = {}
        @resource_map.actions().each do |map_action|
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
          # NOTE: replace any spaces in the name with an '_'.
          resource_name = resource_name.gsub(/[ ]+/, '_')
          resource_name = resource_name.gsub(/#38;/, '')
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
      return @reference_action_defs.key?(resource_path) ? @reference_action_defs[resource_path] : []
    end
  end
end
