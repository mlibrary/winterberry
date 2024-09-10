module UMPTG::Fulcrum::Metadata
  require_relative(File.join("filters", "resourcemetadatafilter"))

  FILTERS = {
      resource_metadata: Filters::ResourceMetadataFilter
    }

  def self.ResourceMetadataFilter(args = {})
    return FILTERS[:resource_metadata].new(args)
  end
end
