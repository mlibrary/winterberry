module UMPTG::Resources

  require 'nokogiri'

  # Class selects XML elements that contain resources
  # to embed|link
  class SpecReferenceSelector < ReferenceSelector

  @@SELECTION_XPATH = <<-SXPATH
  //*[
  (local-name()='p' and @class='fig')
  or (local-name()='figure' and count(*[local-name()='p' and @class='fig'])=0)
  or @class='rb'
  or @class='rbi'
  ]
  SXPATH

    # Method select the references found within the XML tree
    def references(xml_doc)
      return xml_doc.xpath(@@SELECTION_XPATH)
    end

    # Method determines whether a reference is either a
    # resource to be embed|link, or an additional resource
    # to be inserted
    def reference_type(node)
      attr = node.attribute("class")
      unless attr.nil?
        attr = attr.text.downcase
        return :marker if attr == "rb" or attr == "rbi"
      end
      return :element
    end
  end
end
