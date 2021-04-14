module UMPTG::Fulcrum::Resources

  require 'nokogiri'

  # Class selects XML elements that contain resources
  # to embed|link with content delivered by vendor Rekihaku
  class RekihakuReferenceSelector < ReferenceSelector

  @@SELECTION_XPATH = <<-SXPATH
  //*[
  local-name()='div' and @class='fig'
  ]
  SXPATH

    # Method select the references found within the XML tree
    def references(xml_doc)
      return xml_doc.xpath(@@SELECTION_XPATH) + xml_doc.xpath("//comment()")
    end
  end
end
