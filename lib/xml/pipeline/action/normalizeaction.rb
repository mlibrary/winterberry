module UMPTG::XML::Pipeline::Action

  class NormalizeAction < Action

    def initialize(args = {})
      super(args)

      @normalize = true
    end
  end
end
