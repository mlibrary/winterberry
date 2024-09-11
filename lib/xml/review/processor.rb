module UMPTG::XML::Review

  class Processor < UMPTG::XML::Pipeline::Processor
    def initialize(args = {})
      args[:filters] = FILTERS
      super(args)
    end
  end
end
