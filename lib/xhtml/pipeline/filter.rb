module UMPTG::XHTML::Pipeline
  require_relative(File.join("filter", "imgalttextfilter"))
  require_relative(File.join("filter", "extdescrfilter"))
  require_relative(File.join("filter", "resourcemetadatafilter"))

  FILTERS = {
        xhtml_img_alttext: UMPTG::XHTML::Pipeline::Filter::ImgAltTextFilter,
        xhtml_extdescr: UMPTG::XHTML::Pipeline::Filter::ExtDescrFilter,
        xhtml_resource_metadata: UMPTG::XHTML::Pipeline::Filter::ResourceMetadataFilter
      }

  def self.ImgAltTextFilter(args = {})
    return FILTERS[:xhtml_img_alttext].new(args)
  end

  def self.ExtDescrFilter(args = {})
    return FILTERS[:xhtml_extdescr].new(args)
  end

  def self.ResourceMetadataFilter(args = {})
    return FILTERS[:xhtml_resource_metadata].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
