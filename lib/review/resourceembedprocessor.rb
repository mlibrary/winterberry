module UMPTG::Review

  # Class processes each resource reference found within XML content.
  class ResourceEmbedProcessor < EntryProcessor
    attr_accessor :manifest, :reference_actions

    RESOURCE_REFERENCE_XPATH = <<-SXPATH
    //*[
    local-name()='img'
    or (local-name()='figure' and @data-fulcrum-embed-filename)
    ]
    SXPATH

    # Processing parameters:
    #   :selector               Class for selecting resource references
    #   :logger                 Log messages
    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: RESOURCE_REFERENCE_XPATH
            )
      super(args)
      @manifest = nil
      @reference_actions = @properties[:resource_actions]
    end

    def new_action(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      reference_node = args[:reference_node]

      reference_action_list = []
      case reference_node.name
      when 'img'
        resource_path = reference_node['src']
        msg = "#{reference_node.name}: found resource reference #{resource_path}"
      when 'figure'
        resource_path = reference_node['data-fulcrum-embed-filename']
        msg = "#{reference_node.name}: found additional resource reference #{resource_path}"
      end

      reference_action_def_list = @reference_actions.def_list(resource_path)
      reference_action_def_list.each do |reference_action_def|
        case reference_action_def.action_str
        when :embed
          #embed_fragment = @manifest.fileset_embed_markup(resource_path)
          embed_fragment = @manifest.fileset_embed_markup(reference_action_def.resource_name)
          #embed_fragment = reference_action_def.fileset_embed_markup()
          if embed_fragment.nil? or embed_fragment.empty?
            a = Action.new(
                         name: name,
                         reference_node: reference_node,
                         info_message: msg
                      )
            a.add_warning_msg("#{reference_node.name}: no embed markup for resource reference #{resource_path}")
            reference_action_list << a
          else
            reference_action_list << EmbedElementAction.new(
                         name: name,
                         reference_node: reference_node,
                         resource_path: resource_path,
                         embed_fragment: embed_fragment,
                         manifest: @manifest,
                         info_message: msg
                      )
          end
        when :link
          #reference_action = LinkMarkerAction.new(args)
        when :remove
          #reference_action = RemoveElementAction.new(args)
        when :none
          #reference_action = NoneAction.new(args)
        else
          raise "Invalid marker action #{reference_action_def.action_str}"
        end
      end
      return reference_action_list
    end
  end
end
