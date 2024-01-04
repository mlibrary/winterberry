module UMPTG::XML::Pipeline::Actions

  class NormalizeAction < UMPTG::XML::Pipeline::Action

    def initialize(args = {})
      super(args)

      @normalize = true
    end
  end
end
