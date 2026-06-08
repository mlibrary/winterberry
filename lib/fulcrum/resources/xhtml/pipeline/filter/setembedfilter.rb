module UMPTG::Fulcrum::Resources::XHTML::Pipeline::Filter

  class SetEmbedFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='img'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
            process,
            :xhtml_set_embed,
            XPATH,
            options: options
        )
    end

    def review(issue, options: {})
      return unless name == issue.name

      reference_node = issue.content  # <img> element

      raise "unknown element #{reference_node.name}" unless reference_node.name == 'img'

      exceptions = []
=begin
      exceptions = [
          "cover.jpg",
          "fulcrum.jpg",
          "logo.jpg",
          "9798895060278_C001_001",
          "9798895060278_C002_016",
          "9798895060278_C004_001",
          "9798895060278_C006_005",
          "9798895060278_C007_001",
          "9798895060278_C008_002",
          "9798895060278_C008_003",
        ]
=end

      action_list = []

      src = reference_node['src'] || ""
      if exceptions.include?(File.basename(src)) or exceptions.include?(File.basename(src, ".*"))
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: issue.name,
                 reference_node: reference_node,
                 info_message: \
                   "#{reference_node.name}:  found img/@src=\"#{src}\". Attribute data-fulcrum-embed not set."
             )
      else
        action_list << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                 name: issue.name,
                 reference_node: reference_node,
                 attribute_name: "data-fulcrum-embed",
                 attribute_value: "false",
                 info_message: \
                   "#{reference_node.name}: found img/@src=\"#{src}\""
             )
      end

      issue.actions = action_list

      return
    end
  end
end
