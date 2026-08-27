module UMPTG::Journal::Resource
  require_relative(File.join("filter", "resourcefilter"))

  FILTERS = {
        jats_resource: UMPTG::Journal::Resource::Filter::ResourceFilter
      }
end
