module UMPTG::Fulcrum::Metadata

  class Processor < UMPTG::XML::Pipeline::OptionProcessor

    def initialize(args = {})
      a = args.clone

      a[:filters] = FILTERS
      a[:options] = {
          resource_metadata: true
        }
      super(a)
    end
  end
end
