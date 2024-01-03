module UMPTG::XML::Reviewer::Action

  require_relative("normalizefigureaction")

  class NormalizeFigureCaptionStyleAction < NormalizeFigureAction

    def process(args = {})
      super(args)

      resource_path = @properties[:resource_path]

      style = @reference_node["style"]
      @reference_node.remove_attribute("style")
      add_info_msg("image: \"#{resource_path}\" removed @style=\"#{style}\" from caption element #{@reference_node.name}.")

      #@status = Action.COMPLETED
      @status = UMPTG::Action.COMPLETED
    end
  end
end
