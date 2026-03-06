module UMPTG::Fulcrum::Resources::XHTML::Pipeline::Filter

  class UpdateHREFFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='a'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
            process,
            :xhtml_update_href,
            XPATH,
            options: options
        )
    end

    def review(issue, options: {})
      name = issue.name
      reference_node = issue.content  # <a> element

      raise "unknown element #{reference_node.name}" unless reference_node.name == 'a'

      action_list = []

      href = reference_node["href"]
      case
      when href.nil?
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 warning_message: \
                   "#{reference_node.name}: found link with no @href value"
             )
      when href.start_with?('https://www.fulcrum.org/concern/file_sets/')
        fileset_noid = href.delete_prefix('https://www.fulcrum.org/concern/file_sets/')
        fileset = process.manifest.fileset_from_noid(fileset_noid)
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
                   info_message: \
                     "#{reference_node.name}: found Fulcrum fileset #{href}"
               )
          action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                   name: name,
                   reference_node: reference_node,
                   action: :replace_content,
                   markup: fileset["doi"]
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
