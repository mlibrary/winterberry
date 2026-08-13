module UMPTG::Pipeline

  class NormalizeAction < UMPTG::Pipeline::Action
    attr_accessor :resolved_content

    def initialize(issue, options: {})
      super(
            issue,
            options: options
          )
      @normalize = true
      @resolved_content = nil
    end
  end
end
