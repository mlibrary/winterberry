module UMPTG::XML::Reviewer

  class Processor < UMPTG::XML::Processor::Processor
    @@REVIEW_FILTERS = {
          link: UMPTG::XML::Reviewer::Filter::LinkFilter.new,
          package: UMPTG::XML::Reviewer::Filter::PackageFilter.new,
          resource: UMPTG::XML::Reviewer::Filter::ResourceFilter.new
        }

    def initialize(args = {})
      args[:filters] = @@REVIEW_FILTERS
      super(args)
    end
  end
end
