module UMPTG::Fulcrum::Metadata::XHTML::Pipeline
  require_relative(File.join("filter", "resourcemetadatafilter"))

  FILTERS = {
      xhtml_resource_metadata: Filter::ResourceMetadataFilter
    }

  def self.FILTERS
    return FILTERS
  end
end
