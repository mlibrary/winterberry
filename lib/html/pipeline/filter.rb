module UMPTG::HTML::Pipeline
  require_relative(File.join("filter", "imgalttextfilter"))
  require_relative(File.join("filter", "extdescrfilter"))

  FILTERS = {
        html_img_alttext: UMPTG::HTML::Pipeline::Filter::ImgAltTextFilter,
        html_extdescr: UMPTG::HTML::Pipeline::Filter::ExtDescrFilter
      }

  def self.ImgAltTextFilter(args = {})
    return FILTERS[:html_img_alttext].new(args)
  end

  def self.ExtDescrFilter(args = {})
    return FILTERS[:html_extdescr].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
