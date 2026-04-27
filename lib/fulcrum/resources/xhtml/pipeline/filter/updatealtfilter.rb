module UMPTG::Fulcrum::Resources::XHTML::Pipeline::Filter

  class UpdateAltFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='img'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
            process,
            :xhtml_update_alt,
            XPATH,
            options: options
        )
    end

    def review(issue, options: {})
      raise "unknown element #{issue.content.name}" unless issue.content.name == 'img'

      action_list = []

      alt = (issue.content["alt"] || "").strip
      src = File.basename((issue.content['src'] || "").strip, ".*")
      fileset = process.manifest.fileset(src)
      if fileset['file_name'].empty?
        action = UMPTG::XML::Pipeline::Action.new(
                 name: issue.name,
                 reference_node: issue.content,
                 warning_message: \
                   "#{issue.name}: #{issue.content.name}, found @src=\"#{src}\" @alt=\"#{alt}\", no resource found"
             )
      else
        action = UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                 name: issue.name,
                 reference_node: issue.content,
                 attribute_name: "alt",
                 attribute_value: fileset["alternative_text"],
                 info_message: \
                   "#{issue.name}: #{issue.content.name}, found @src=\"#{src}\" @alt=\"#{alt}\""
             )
      end
      action_list << action
      return action_list
    end
  end
end
