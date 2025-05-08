module UMPTG::HTML::Pipeline

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      a = args.clone

      a[:filters] = FILTERS

      super(a)
    end
  end
end
