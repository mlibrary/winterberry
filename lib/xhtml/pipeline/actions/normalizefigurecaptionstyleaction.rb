module UMPTG::XHTML::Pipeline::Actions

  class NormalizeFigureCaptionStyleAction < UMPTG::Pipeline::NormalizeAction

    def resolve(options: {})
      super(options: options)

      resource_path = @properties[:resource_path]

      style = @reference_node["style"]
      @reference_node.remove_attribute("style")
      add_info_msg("#{name}: \"#{resource_path}\" removed @style=\"#{style}\" from caption element #{@reference_node.name}.")

      @status = UMPTG::XML::Pipeline::Actions::NormalizeAction.COMPLETED
    end
  end
end
