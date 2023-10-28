module UMPTG::XML::Reviewer

  class Processor < UMPTG::XML::Processor::Processor
    @@REVIEW_FILTERS = {
          link: UMPTG::XML::Reviewer::Filter::LinkFilter.new,
          package: UMPTG::XML::Reviewer::Filter::PackageFilter.new,
          resource: UMPTG::XML::Reviewer::Filter::ResourceFilter.new
        }

    def initialize(args = {})
      if args.key?(:options)
        options = args[:options]
        review_filters = @@REVIEW_FILTERS.select {|key,proc| options[key] == true }
      else
        review_filters = @@REVIEW_FILTERS
      end

      args[:filters] = review_filters.values
      super(args)
    end
  end
end
