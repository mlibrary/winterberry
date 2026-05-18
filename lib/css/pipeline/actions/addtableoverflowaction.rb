module UMPTG::CSS::Pipeline

  class AddTableOverflowAction < UMPTG::XML::Pipeline::Actions::NormalizeAction
    attr_reader :name, :content

    def initialize(args = {})
      super(args)

      @issue = @properties[:issue]
      @add_content = @properties[:add_content]
    end

    def resolve(args = {})
      super(args)

      @issue.content += "\n\n" + @add_content
      add_info_msg("#{@issue.name}, added table overflow CSS")
      @status = UMPTG::XML::Pipeline::Action.COMPLETED
    end
  end
end
