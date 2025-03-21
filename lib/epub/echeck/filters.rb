module UMPTG::EPUB::ECheck
  require_relative(File.join("filters", "ncxfilter"))
  require_relative(File.join("filters", "opffilter"))
  require_relative(File.join("filters", "xhtmlfilter"))

  FILTERS = {
        ncx: UMPTG::EPUB::ECheck::Filter::NCXFilter,
        opf: UMPTG::EPUB::ECheck::Filter::OPFFilter,
        xhtml: UMPTG::EPUB::ECheck::Filter::XHTMLFilter
      }
end
