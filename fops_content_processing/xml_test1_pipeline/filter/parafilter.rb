module XMLTest1Pipeline

  class ParaFilter < UMPTG::XML::Pipeline::Filter

    def initialize(options: nil)
      super(
            name: :xml_test1_para,
            xpath: "//*[local-name()='p']",
            options: options
          )
    end

    def review(issue, options: nil)
      return unless issue.name == name

      super(
              issue,
              options: options
           )
      issue.actions.last.add_info_msg("#{name}, issue #{issue.name} found element #{issue.content.name}")
    end
  end
end
