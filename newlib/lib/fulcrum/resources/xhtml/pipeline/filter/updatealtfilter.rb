module UMPTG::Fulcrum::Resources::XHTML::Pipeline::Filter

  class UpdateAltFilter < UMPTG::Fulcrum::Filter::ManifestFilter

    XPATH = <<-SXPATH
    //*[
    local-name()='img'
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :xhtml_update_alt
      args[:xpath] = XPATH
      super(args)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <img> element

      raise "unknown element #{reference_node.name}" unless reference_node.name == 'img'

      action_list = []

      alt = (reference_node["alt"] || "").strip
      src = File.basename((reference_node['src'] || "").strip, ".*")
      fileset = manifest.fileset(src)
      if fileset['file_name'].empty?
        action = UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 warning_message: \
                   "#{name}: #{reference_node.name}, found @src=\"#{src}\" @alt=\"#{alt}\", no resource found"
             )
      else
        action = UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                 name: name,
                 reference_node: reference_node,
                 attribute_name: "alt",
                 attribute_value: fileset["alternative_text"],
                 info_message: \
                   "#{name}: #{reference_node.name}, found @src=\"#{src}\" @alt=\"#{alt}\""
             )
      end
      action_list << action
      return action_list
    end
  end
end
