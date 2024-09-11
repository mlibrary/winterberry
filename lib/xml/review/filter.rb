module UMPTG::XML::Review
  require_relative(File.join("filter", "linkfilter"))
  require_relative(File.join("filter", "packagefilter"))
  require_relative(File.join("filter", "resourcefilter"))

  FILTERS = {
        link: UMPTG::XML::Review::Filter::LinkFilter,
        package: UMPTG::XML::Review::Filter::PackageFilter,
        resource: UMPTG::XML::Review::Filter::ResourceFilter
      }

end
