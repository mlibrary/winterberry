module UMPTG::Fulcrum::Metadata::XHTML::Pipeline
  require_relative(File.join("filter", "resourcemetadatafilter"))

  FILTERS = {
      xhtml_resource_metadata: Filter::ResourceMetadataFilter
    }

  def self.ResourceMetadataFilter(args = {})
    return FILTERS[:xhtml_resource_metadata].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
