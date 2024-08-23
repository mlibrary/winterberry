module UMPTG::Fulcrum::Resources::Filter

  class FulcrumCSSFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    /*[
    local-name()='html'
    ]/*[
    local-name()='head'
    ]/*[
    local-name()='link'
    ][
    last()
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :fulcrum_css unless args.key?(:name)
      args[:xpath] = XPATH
      super(args)
    end

    def create_actions(args = {})
      a = args.clone

      # last CSS link
      reference_node = a[:reference_node]

      action_list = []
      a[:markup] = '<link href="../styles/fulcrum_default.css" rel="stylesheet" type="text/css"/>'
      action_list << UMPTG::XML::Pipeline::Actions::NormalizeInsertMarkupAction.new(a)

      return action_list
    end
  end
end
