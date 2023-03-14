module UMPTG::Fulcrum::Keywords

  require 'nokogiri'

  # Class selects XML elements that contain keywords
  # to be linked to Fulcrum pages.
  class SpecKeywordSelector

  # XPath expression for retrieving keywords
@@SELECTION_XPATH = <<-SXPATH
//*[
local-name()='span' and @data-fulcrum-keyword
]
SXPATH

    def references(xml_doc)
      return xml_doc.xpath(@@SELECTION_XPATH)
    end
  end
end
