module UMPTG::CSS::Pipeline

  class AddTableOverflowAction < UMPTG::Pipeline::NormalizeAction
    attr_reader :issue, :add_content

    def initialize(issue, options: {})
      super(issue, options: options)

      @add_content = options[:add_content]
    end

    def resolve(options: {})
      super(options: options)

      @issue.content += "\n\n" + @add_content
      add_info_msg("#{@issue.name}, added table overflow CSS")
      @status = UMPTG::XML::Pipeline::Action.COMPLETED
    end
  end
end
