module UMPTG::HTML
  require_relative(File.join("filter", "imgalttextfilter"))

  FILTERS = {
        alt_text: UMPTG::HTML::Filter::ImgAltTextFilter
      }
end
