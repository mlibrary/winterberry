module UMPTG::Fulcrum::Resources::Filter

  class RemoveFigcaptionFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    and @data-fulcrum-embed-filename
    ]/*[
    local-name()='figcaption'
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :remove_figcaption
      args[:xpath] = XPATH
      super(args)
    end

    def create_actions(args = {})
      a = args.clone
      a[:action_node] = a[:reference_node]
      return [
            UMPTG::XML::Pipeline::Actions::RemoveElementAction.new(a)
          ]
    end
  end
end
