module UMPTG::XHTML::Pipeline::Filter

  class FigureFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    ]
    SXPATH

    def initialize(options: nil)
      super(
              name: :xhtml_figure,
              xpath: XPATH,
              options: options
            )
    end

    def resolve(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      name = issue.name
      reference_node = issue.content  # <figure> element

      if reference_node.name == 'figure'
        id = reference_node['id'] || ""
        issue.actions << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 info_message: \
                   "#{name}, #{reference_node.name} found @id=\"#{id}\""
             )
=begin
        if reference_node['style'] == 'display:none'
          issue.actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                   name: name,
                   reference_node: reference_node,
                   attribute_name: "style",
                   info_message: \
                     "#{name}, #{reference_node.name} found @style=\"#{reference_node['style']}\""
               )
        end
=end
      end
    end
  end
end
