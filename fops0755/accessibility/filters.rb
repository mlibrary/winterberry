module UMPTG::Accessibility
  require_relative(File.join("filters", "opffilter"))
=begin
  require_relative(File.join("filters", "ncxfilter"))
  require_relative(File.join("filters", "xhtmlfilter"))
=end

  FILTERS = {
        opf: UMPTG::Accessibility::Filter::OPFFilter,
=begin
        ncx: UMPTG::Accessibility::Filter::NCXFilter,
        xhtml: UMPTG::Accessibility::Filter::XHTMLFilter
=end
      }
end
