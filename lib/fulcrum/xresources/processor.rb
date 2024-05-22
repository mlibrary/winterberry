module UMPTG::Fulcrum::XResources

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      a = args.clone
      a[:filters] = {
            embed_link: Filter::EmbedLinkFilter.new(args)
          }
      super(a)
    end
  end
end
