module UMPTG::Fulcrum::XResources

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      a = args.clone

      options = a[:options]
      options = options.nil? ? {} : options

      a[:filters] = {}
      options.each do |k,v|
        next unless v

        case k
        when :embed_link
          filter = Filter::EmbedLinkFilter.new(args)
        when :update_alt
          filter = Filter::UpdateAltTextFilter.new(args)
        else
          next
        end
        a[:filters][k] = filter
      end
      raise "No filters defined" if a[:filters].empty?

      super(a)
    end
  end
end
