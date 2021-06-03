module UMPTG::Fulcrum::Resources

  require 'nokogiri'

  # Class is base for resource reference selection.
  class ReferenceSelector < UMPTG::Object
    @@SELECTION_XPATH = nil

    def references(xml_doc, xpath = @@SELECTION_XPATH)
      return [] if xpath.nil?
      return xml_doc.xpath(xpath)
    end

    def reference_type(node)
      return node.comment? ? :marker : :element
    end
  end
end
