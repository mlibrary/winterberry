module UMPTG::XHTML::Pipeline::Filter

  class FigureFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_figure,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      if issue.content.name == 'figure'
        id = issue.content['id'] || ""
        issue.actions << UMPTG::XML::Pipeline::Action.new(
                 name: issue.name,
                 reference_node: issue.content,
                 info_message: \
                   "#{issue.name}, #{issue.content.name} found @id=\"#{id}\""
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
