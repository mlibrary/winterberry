module UMPTG::Pipeline

  class NormalizeAction < UMPTG::Pipeline::Action

    def initialize(issue, options: nil)
      super(
            issue,
            options: options
          )
      @normalize = true
    end

    def process(options: nil)
      super(
              options: options
          )
    end
  end
end
