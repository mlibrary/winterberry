module UMPTG::Resources

  require 'nokogiri'

  class SpecReferenceSelector

  @@SELECTION_XPATH = <<-SXPATH
  //*[
  (local-name()='p' and @class='fig')
  or (local-name()='figure' and count(*[local-name()='p' and @class='fig'])=0)
  or @class='rb'
  or @class='rbi'
  ]
  SXPATH

    def references(xml_doc)
      return xml_doc.xpath(@@SELECTION_XPATH)
    end

    def reference?(node)
      attr = node.attribute("class")
      unless attr.nil?
        attr = attr.text.downcase
        return :marker if attr == "rb" or attr == "rbi"
      end
      return :element
    end
  end
end
