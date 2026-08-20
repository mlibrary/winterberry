module UMPTG::Fulcrum::Metadata::XHTML::Pipeline::Filter

  class ResourceMetadataFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='figure' and count(descendant::*[local-name()='figure'])=0
    ] | //*[
    local-name()='img' and count(ancestor::*[local-name()='figure'])=0
    ] | //*[
    @data-fulcrum-embed-filename and local-name()!='figure'
    ]
    SXPATH

    def initialize(processor, options: nil)
      super(
              processor,
              :xhtml_resource_metadata,
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

      name = issue.name
      reference_node = issue.content

      if reference_node.key?("data-fulcrum-embed-filename")
        action = UMPTG::XHTML::Pipeline::Actions::MarkerAction.new(
                             issue
                             )
      else
        action = UMPTG::XHTML::Pipeline::Actions::FigureAction.new(
            issue
            )
      end

      issue.actions << action
    end
  end
end