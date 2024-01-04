module UMPTG::XML::Review

  class Processor < UMPTG::XML::Pipeline::Processor
    @@REVIEW_FILTERS = {
          link: UMPTG::XML::Review::Filter::LinkFilter.new,
          package: UMPTG::XML::Review::Filter::PackageFilter.new,
          resource: UMPTG::XML::Review::Filter::ResourceFilter.new
        }

    def initialize(args = {})
      args[:filters] = @@REVIEW_FILTERS
      super(args)
    end
  end
end
