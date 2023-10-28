module UMPTG::XML::Processor::Action

  class NormalizeAction < Action

    def initialize(args = {})
      super(args)

      @normalize = true
    end
  end
end
