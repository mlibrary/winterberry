module UMPTG::EPUB::ECheck
  require_relative(File.join("filters", "ncxfilter"))
=begin
  require_relative(File.join("filters", "opffilter"))
=end
  require_relative(File.join("filters", "xhtmlfilter"))

  FILTERS = {
        ncx: UMPTG::EPUB::ECheck::Filter::NCXFilter,
=begin
        opf: UMPTG::EPUB::ECheck::Filter::OPFFilter,
=end
        xhtml: UMPTG::EPUB::ECheck::Filter::XHTMLFilter
      }
end
