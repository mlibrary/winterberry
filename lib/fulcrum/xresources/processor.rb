module UMPTG::Fulcrum::XResources

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      a = args.clone
      a[:filters] = {
            embed_link: Filter::EmbedLinkFilter.new(
                  manifest: args[:manifest]
                )
          }
      super(a)
    end
  end
end
