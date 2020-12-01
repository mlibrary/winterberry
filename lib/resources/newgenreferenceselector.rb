module UMPTG::Resources

  require 'nokogiri'

  class NewgenReferenceSelector < ReferenceSelector

  @@SELECTION_XPATH = <<-SXPATH
  //*[
  local-name()='div' and @class='figurewrap'
  ]
  SXPATH

    def references(xml_doc)
      return xml_doc.xpath(@@SELECTION_XPATH) + xml_doc.xpath("//comment()")
    end
  end
end
