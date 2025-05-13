module UMPTG::Fulcrum::Metadata
  require_relative(File.join("filter", "resourcemetadatafilter"))

  FILTERS = {
      resource_metadata: Filter::ResourceMetadataFilter
    }

  def self.ResourceMetadataFilter(args = {})
    return FILTERS[:resource_metadata].new(args)
  end
end
