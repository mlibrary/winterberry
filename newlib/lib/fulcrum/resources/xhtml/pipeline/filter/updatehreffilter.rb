module UMPTG::Fulcrum::Resources::XHTML::Pipeline::Filter

  class UpdateHREFFilter < UMPTG::Fulcrum::Filter::ManifestFilter

    XPATH = <<-SXPATH
    //*[
    local-name()='a'
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :xhtml_update_href
      args[:xpath] = XPATH
      super(args)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <a> element

      raise "unknown element #{reference_node.name}" unless reference_node.name == 'a'

      action_list = []

      href = reference_node["href"]
      if href.start_with?('https://www.fulcrum.org/concern/file_sets/')
        fileset_noid = href.delete_prefix('https://www.fulcrum.org/concern/file_sets/')
        fileset = manifest.fileset_from_noid(fileset_noid)
        if fileset["noid"].empty?
          action_list << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: \
                     "#{reference_node.name}: no Fulcrum fileset for #{href}"
               )
        else
          action_list << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                   name: name,
                   reference_node: reference_node,
                   attribute_name: "href",
                   attribute_value: fileset["doi"],
                   warning_message: \
                     "#{reference_node.name}: found Fulcrum fileset #{href}"
               )
        end
      else
          action_list << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   info_message: \
                     "#{reference_node.name}: found link #{href}"
               )
      end

      return action_list
    end
  end
end
