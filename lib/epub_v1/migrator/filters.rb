module UMPTG::EPUB::Migrator
  require_relative(File.join("filters", "ncxfilter"))
  require_relative(File.join("filters", "opffilter"))
  require_relative(File.join("filters", "xhtmlfilter"))

  FILTERS = {
        ncx: UMPTG::EPUB::Migrator::Filter::NCXFilter,
        opf: UMPTG::EPUB::Migrator::Filter::OPFFilter,
        xhtml: UMPTG::EPUB::Migrator::Filter::XHTMLFilter
      }
end
