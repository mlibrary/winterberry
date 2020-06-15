class ResourceProcessor
	def initialize(args)
		@processor_args = args

		@resource_actions = nil
	end

	def process(doc)
	  init_resource_actions

    reference_processor = @processor_args[:reference_processor]

    options = @processor_args[:options]

		args = @processor_args.clone

    args[:xml_doc] = doc

    resource_action_list = reference_processor.resource_actions(args)
    resource_action_list.each do |resource_action|
      if options.execute
        resource_action.process
      end
      puts resource_action
      puts resource_action.message unless resource_action.message.nil? or resource_action.message.empty?
    end

    return resource_action_list
	end

	private

	def init_resource_actions
	  if @processor_args[:resource_actions].nil?
	    resource_map = @processor_args[:resource_map]
      manifest = @processor_args[:resource_metadata]
      default_action_str = @processor_args[:default_action_str]

      # Generate the resource action list.
      actions_list = []
      map_actions = resource_map.actions
      map_actions.each do |map_action|
        reference_name = map_action.reference.name
        resource_name = map_action.resource.name

        if resource_name == nil or resource_name.strip.empty?
          puts "Warning: no resource  mapping found for reference #{File.basename(reference_name)}"
          next
        end

        # Use file_name to find manifest row. Could use the NOID found in
        # the resource map, but it is possible that these may be invalid if
        # the monograph has been moved or fileset have been replaced.
        fileset_row = manifest.fileset(resource_name)
        if fileset_row['noid'].empty?
          puts "Error: no fileset row for resource #{resource_name}"
          link = fileset_row['link']
        else
          puts "Reference #{File.basename(reference_name)} mapped to resource #{resource_name}"
          link = fileset_row['link'].match('^[^\(]+\(\"([^\"]+)\".*') {|m| m[1] }
        end

        map_action.type = default_action_str if map_action.type == "default"
        reference_action = ReferenceAction.new(
                    :resource_map_action => map_action,
                    :resource_metadata => fileset_row
                  )
        actions_list << reference_action
      end
      @processor_args[:resource_actions] = actions_list
    end
	end
end
