module UMPTG::Fulcrum::Resources

  require 'nokogiri'

  # Class selects XML elements that contain resources
  # to embed|link with content delivered by vendor Newgen
  class NewgenReferenceSelector < ReferenceSelector

  @@NEWGEN_SELECTION_XPATH = <<-SXPATH
  //*[local-name()='div' and @class='figurewrap']
  SXPATH

    # Method select the references found within the XML tree
    def references(xml_doc)
      return super(xml_doc, @@NEWGEN_SELECTION_XPATH) + xml_doc.xpath("//comment()")
    end
  end
end
