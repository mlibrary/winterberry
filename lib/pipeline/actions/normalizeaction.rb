module UMPTG::Pipeline

  class NormalizeAction < UMPTG::Pipeline::Action

    def initialize(issue, options: {})
      super(
            issue,
            options: options
          )
      @normalize = true
    end
  end
end
