module UMPTG::Fulcrum::Resources::Filter

  class UpdateAltTextFilter < UMPTG::Fulcrum::Filter::ManifestFilter

    IMG_XPATH = <<-SXPATH
    //*[
    local-name()='img'
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :update_alt

      raise "manifest required" if args[:manifest].nil?

      args[:xpath] = IMG_XPATH
      super(args)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # img element
      reference_name = reference_node["src"]

      action_list = []
      if reference_name.nil? or reference_name.strip.empty?
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 warning_message: "#{reference_node.name}: image with no @src value"
             )
        return
      end

      reference_alt = reference_node["alt"]
      reference_alt = reference_alt.nil? ? "" : reference_alt.strip
      resource_alt = manifest.fileset_alt(reference_name)
      resource_alt = resource_alt.nil? ? "" : resource_alt.strip

      if reference_alt.empty?
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 warning_message: "#{reference_name}: empty reference alt text"
             )
      end
      if resource_alt.empty?
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 warning_message: "#{reference_name}: empty resource alt text"
             )
      end
      unless reference_alt.empty? or resource_alt.empty?
        unless reference_alt == resource_alt
          action_list << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: "#{reference_name}: updating reference with resource alt text"
               )
        end
      end
      return action_list
    end
  end
end
