module UMPTG::XHTML::Pipeline
  require_relative(File.join("filter", "imgalttextfilter"))
  require_relative(File.join("filter", "extdescrfilter"))

  FILTERS = {
        xhtml_img_alttext: UMPTG::XHTML::Pipeline::Filter::ImgAltTextFilter,
        xhtml_extdescr: UMPTG::XHTML::Pipeline::Filter::ExtDescrFilter
      }

  def self.ImgAltTextFilter(args = {})
    return FILTERS[:xhtml_img_alttext].new(args)
  end

  def self.ExtDescrFilter(args = {})
    return FILTERS[:xhtml_extdescr].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
